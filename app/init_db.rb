DB = SQLite3::Database.new 'db/data.db'

DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    webauthn_id TEXT UNIQUE,
    name TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
  );
SQL

DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS credentials (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    webauthn_id TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    public_key TEXT NOT NULL,
    transports JSON NOT NULL,
    sign_count INTEGER
  );
SQL
