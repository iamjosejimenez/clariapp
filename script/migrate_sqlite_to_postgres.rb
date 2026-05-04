#!/usr/bin/env ruby
# frozen_string_literal: true

# Migra los datos de un archivo SQLite (storage/production.sqlite3) a Postgres (Neon).
#
# Uso:
#   DATABASE_URL=postgresql://user:pass@host/db ruby script/migrate_sqlite_to_postgres.rb /tmp/storage/production.sqlite3
#
# Pre-requisitos:
#   - Schema de Postgres ya creado (correr `bin/rails db:migrate` apuntando al destino antes).
#   - DATABASE_URL apuntando al destino Postgres.
#   - Argumento: ruta absoluta al archivo SQLite origen.
#
# Comportamiento:
#   - Trunca cada tabla destino antes de insertar (idempotente).
#   - Migra tablas de la app en orden de FK. NO migra solid_queue/cache/cable.
#   - Resetea las secuencias auto-increment de Postgres al MAX(id).
#   - Verifica conteos de filas al final.

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "sqlite3"
  gem "pg"
end

require "uri"

SQLITE_PATH = ARGV[0] or abort("Uso: ruby #{$0} <ruta_sqlite>")
abort("No existe el archivo: #{SQLITE_PATH}") unless File.exist?(SQLITE_PATH)

DATABASE_URL = ENV["DATABASE_URL"] or abort("Falta DATABASE_URL")

# Orden de FK: padres antes que hijos.
TABLES = %w[
  users
  sessions
  external_accounts
  goals
  goal_snapshots
  budgets
  budget_periods
  expenses
  news_summaries
  news_items
].freeze

def connect_pg(url)
  uri = URI.parse(url)
  PG.connect(
    host: uri.host,
    port: uri.port || 5432,
    user: uri.user,
    password: uri.password,
    dbname: uri.path[1..],
    sslmode: URI.decode_www_form(uri.query.to_s).to_h["sslmode"] || "prefer"
  )
end

sqlite = SQLite3::Database.new(SQLITE_PATH)
sqlite.results_as_hash = true

pg = connect_pg(DATABASE_URL)

puts "Origen: #{SQLITE_PATH}"
puts "Destino: #{URI.parse(DATABASE_URL).host}/#{URI.parse(DATABASE_URL).path[1..]}"
puts

pg.exec("SET session_replication_role = 'replica'") # desactiva FK temporalmente

TABLES.each do |table|
  rows = sqlite.execute("SELECT * FROM #{table}")
  puts "[#{table}] #{rows.size} filas en SQLite"

  pg.exec("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE")
  next if rows.empty?

  columns = rows.first.keys.reject { |k| k.is_a?(Integer) }
  placeholders = columns.each_with_index.map { |_, i| "$#{i + 1}" }.join(", ")
  sql = "INSERT INTO #{table} (#{columns.join(', ')}) VALUES (#{placeholders})"

  pg.prepare("ins_#{table}", sql)
  rows.each do |row|
    values = columns.map { |c| row[c] }
    pg.exec_prepared("ins_#{table}", values)
  end

  # Resetea la secuencia al MAX(id) si existe columna id
  if columns.include?("id")
    pg.exec(<<~SQL)
      SELECT setval(
        pg_get_serial_sequence('#{table}', 'id'),
        COALESCE((SELECT MAX(id) FROM #{table}), 1),
        (SELECT MAX(id) IS NOT NULL FROM #{table})
      )
    SQL
  end

  puts "  -> OK"
end

pg.exec("SET session_replication_role = 'origin'")

puts "\nVerificación de conteos:"
TABLES.each do |table|
  src = sqlite.execute("SELECT COUNT(*) FROM #{table}").first.values.first
  dst = pg.exec("SELECT COUNT(*) FROM #{table}").first["count"].to_i
  status = src == dst ? "OK" : "MISMATCH"
  puts "  [#{status}] #{table}: SQLite=#{src} Postgres=#{dst}"
end

sqlite.close
pg.close
puts "\nMigración completada."
