# Optimize SQLite for production
if Rails.env.production?
  Rails.application.config.after_initialize do
    ActiveRecord::Base.connection.execute("PRAGMA journal_mode = WAL")
    ActiveRecord::Base.connection.execute("PRAGMA synchronous = NORMAL")
    ActiveRecord::Base.connection.execute("PRAGMA cache_size = 1000")
    ActiveRecord::Base.connection.execute("PRAGMA temp_store = memory")
  end
end