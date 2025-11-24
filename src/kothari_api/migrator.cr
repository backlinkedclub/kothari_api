module KothariAPI
  module Migrator
    @@migrations_path = "db/migrations"

    # Apply all pending migrations. Tracks applied migrations in the
    # `schema_migrations` table so new migrations can be added later
    # without re-running old ones.
    def self.migrate
      puts "Running migrations..."

      ensure_schema_migrations_table

      applied = applied_versions

      Dir.glob("#{@@migrations_path}/*.sql").sort.each do |file|
        version = extract_version(file)
        next if version.nil?
        next if applied.includes?(version)

        puts "Applying #{File.basename(file)}..."
        sql = File.read(file)
        KothariAPI::DB.conn.exec(sql)

        record_version(version)
      end

      puts "Migrations complete."
    end

    # List of applied migration versions as strings.
    def self.applied_versions : Array(String)
      versions = [] of String
      KothariAPI::DB.conn.query("SELECT version FROM schema_migrations") do |rs|
        while rs.move_next
          versions << rs.read(String)
        end
      end
      versions
    rescue
      [] of String
    end

    # Extracts the leading timestamp/version from a migration filename,
    # e.g. "1763940342450_create_students.sql" -> "1763940342450".
    def self.extract_version(path : String) : String?
      name = File.basename(path)
      if match = name.match(/^(\d+)_/)
        match[1]
      else
        nil
      end
    end

    def self.ensure_schema_migrations_table
      KothariAPI::DB.conn.exec <<-SQL
CREATE TABLE IF NOT EXISTS schema_migrations (
  version TEXT PRIMARY KEY
);
SQL
    end

    def self.record_version(version : String)
      KothariAPI::DB.conn.exec "INSERT OR IGNORE INTO schema_migrations (version) VALUES (?)", version
    end
  end
end
