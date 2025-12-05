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
        
        # Extract UP section if migration has up/down structure
        up_sql = extract_up_section(sql)
        
        # Skip if UP section is empty (e.g., comment-only migrations)
        if up_sql.strip.empty?
          puts "  ⚠ Skipping #{File.basename(file)} (empty UP section - may require manual intervention)"
          record_version(version)
          next
        end
        
        # Execute the UP section (or entire file if no up/down structure)
        KothariAPI::DB.conn.exec(up_sql)

        record_version(version)
      end

      puts "Migrations complete."
    end

    # Extract the UP section from a migration file
    # Migrations can have:
    #   -- UP
    #   <sql statements>
    #   -- DOWN
    #   <sql statements>
    def self.extract_up_section(sql : String) : String
      # Check if migration has up/down structure
      if sql.includes?("-- UP") && sql.includes?("-- DOWN")
        # Extract everything between -- UP and -- DOWN
        parts = sql.split("-- DOWN")
        up_part = parts[0]
        # Remove the -- UP comment line and any leading comments
        up_part = up_part.sub(/^.*?-- UP\s*\n?/m, "")
        # Remove comment-only lines (lines that are only comments or whitespace)
        up_part = up_part.lines.reject { |line| line.strip.empty? || line.strip.starts_with?("--") }.join("\n")
        up_part.strip
      else
        # No up/down structure, return entire file
        sql
      end
    end

    # Extract the DOWN section from a migration file (for rollback)
    def self.extract_down_section(sql : String) : String?
      if sql.includes?("-- UP") && sql.includes?("-- DOWN")
        parts = sql.split("-- DOWN")
        return nil if parts.size < 2
        down_part = parts[1]
        # Remove any trailing comments
        down_part = down_part.sub(/^.*?-- DOWN\s*\n?/m, "")
        down_part.strip
      else
        nil
      end
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
