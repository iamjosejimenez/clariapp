# lib/tasks/data_migrate.rake
require "json"

namespace :data_migrate do
  SKIP_TABLES = %w[
    schema_migrations
    ar_internal_metadata
  ].freeze

  def export_dir
    ENV.fetch("EXPORT_DIR", "storage/pg_export")
  end

  def tables
    ActiveRecord::Base.connection.tables - SKIP_TABLES
  end

  desc "Exporta data desde la DB actual a JSONL por tabla (sin depender de modelos)"
  task export: :environment do
    dir = export_dir
    FileUtils.mkdir_p(dir)

    tables.each do |table|
      path = File.join(dir, "#{table}.jsonl")
      puts "exporting #{table}..."

      # Streaming por batches para no reventar RAM
      offset = 0
      batch  = 2_000

      File.open(path, "w") do |f|
        loop do
          rows = ActiveRecord::Base.connection.exec_query(<<~SQL)
            SELECT * FROM #{ActiveRecord::Base.connection.quote_table_name(table)}
            OFFSET #{offset} LIMIT #{batch}
          SQL

          break if rows.rows.empty?

          cols = rows.columns
          rows.rows.each do |values|
            h = cols.zip(values).to_h
            f.puts(h.to_json)
          end

          offset += batch
        end
      end

      puts "exported #{table} -> #{path}"
    end
  end

  desc "Importa data a la DB actual desde JSONL por tabla (sin depender de modelos)"
  task import: :environment do
    dir = export_dir
    raise "Missing export dir: #{dir}" unless Dir.exist?(dir)

    # Importa en orden alfabético; si tienes FKs estrictas, luego lo ordenamos mejor.
    files = Dir[File.join(dir, "*.jsonl")].sort

    ActiveRecord::Base.connection.disable_referential_integrity do
      files.each do |file|
        table = File.basename(file, ".jsonl")
        puts "importing #{table}..."

        rows = []
        File.foreach(file) do |line|
          rows << JSON.parse(line)
          if rows.size >= 1000
            ActiveRecord::Base.connection.insert_fixtures_set({ table => rows }, [ table ])
            rows.clear
          end
        end

        ActiveRecord::Base.connection.insert_fixtures_set({ table => rows }, [ table ]) if rows.any?
        puts "imported #{table}"
      end
    end
  end
end
