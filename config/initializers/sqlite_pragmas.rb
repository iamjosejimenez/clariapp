ActiveSupport.on_load(:active_record) do
  next unless ActiveRecord::Base.connection.adapter_name == "SQLite"

  ActiveRecord::Base.connection.execute("PRAGMA journal_mode = WAL")
  ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
  ActiveRecord::Base.connection.execute("PRAGMA busy_timeout = 10000")
  ActiveRecord::Base.connection.execute("PRAGMA synchronous = NORMAL")
end
