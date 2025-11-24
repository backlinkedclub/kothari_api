require "db"
require "sqlite3"

module KothariAPI
  module DB
    @@db : ::DB::Database?

    def self.connect(path : String)
      @@db = ::DB.open("sqlite3://#{path}")
    end

    def self.conn
      @@db.not_nil!
    end
  end
end
