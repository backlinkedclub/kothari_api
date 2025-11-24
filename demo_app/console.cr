# Load framework and app code without starting the HTTP server
require "kothari_api"
require "./app/models"
require "./app/controllers"

# Connect to database (same as server does)
KothariAPI::DB.connect("db/development.sqlite3")

puts "[36m╔═══════════════════════════════════════════════════════════╗[0m"
puts "[36m║           KOTHARI API CONSOLE - DATA EXPLORER           ║[0m"
puts "[36m╚═══════════════════════════════════════════════════════════╝[0m"
puts "[33mType 'help' for commands, 'exit' to quit.[0m
"

loop do
  print "[36mkothari>[0m "
  line = gets
  break if line.nil?
  cmd = line.strip
  break if cmd == "exit"

  case cmd
  when "help"
    puts "[32m╔═══════════════════════════════════════════════════════════╗[0m"
    puts "[32m║                    AVAILABLE COMMANDS                  ║[0m"
    puts "[32m╚═══════════════════════════════════════════════════════════╝[0m"
    puts ""
    puts "[33m📋 Model Commands:[0m"
    puts "  [36mmodels[0m                    - List all registered models"
    puts "  [36m<Model>.show[0m              - Show table structure (columns & types)"
    puts "  [36m<Model>.all[0m               - List all records (e.g. Session.all)"
    puts "  [36m<Model>.where(\"condition\")[0m - Query with WHERE clause (e.g. Session.where(\"live = 1\"))"
    puts "  [36m<Model>.find(id)[0m          - Find record by ID (e.g. Session.find(1))"
    puts ""
    puts "[33m🗄️  SQL Commands:[0m"
    puts "  [36msql SELECT ...[0m           - Run SELECT query"
    puts "  [36msql INSERT INTO ...[0m      - Insert new record"
    puts "  [36msql UPDATE ... SET ...[0m   - Update records"
    puts "  [36msql DELETE FROM ...[0m      - Delete records"
    puts "  [36msql CREATE TABLE ...[0m     - Create table"
    puts "  [36msql DROP TABLE ...[0m        - Drop table"
    puts "  [36msql .schema <table>[0m      - Show table schema"
    puts ""
    puts "[33m🔧 Utility:[0m"
    puts "  [36mexit[0m                      - Quit console"
    puts ""
  when "models"
    names = KothariAPI::ModelRegistry.all_names
    if names.empty?
      puts "[33m⚠ No models registered yet.[0m"
    else
      puts "[32m✓ Registered Models:[0m"
      names.each { |n| puts "  [36m• #{n.capitalize}[0m" }
    end
  else
    if cmd.starts_with?("sql ")
      query = cmd[4..].strip
      if query.empty?
        puts "[31m✗ Error: SQL query cannot be empty[0m"
      else
        begin
          KothariAPI::DB.conn.query(query) do |rs|
            cols = rs.column_names
            if cols.empty?
              puts "[33m✓ Query executed successfully (no results)[0m"
            else
              # Print header
              header = cols.join(" | ")
              puts "[36m#{header}[0m"
              puts "-" * header.size
              # Print rows
              count = 0
              rs.each do
                values = cols.map do |col|
                  val = rs.read(String?)
                  val.nil? ? "NULL" : val.to_s
                end
                puts values.join(" | ")
                count += 1
              end
              puts "[33m✓ #{count} row(s)[0m"
            end
          end
        rescue ex
          puts "[31m✗ SQL Error: #{ex.message}[0m"
        end
      end
    elsif cmd.includes?(".show")
      # Handle: Session.show, session.show
      name = cmd.split(".").first.strip.downcase
      if model = KothariAPI::ModelRegistry.lookup(name)
        begin
          table_name = model.table
          puts "[32m╔═══════════════════════════════════════════════════════════╗[0m"
          puts "[32m║  Table: [36m#{table_name}[32m[0m"
          puts "[32m╚═══════════════════════════════════════════════════════════╝[0m"
          
          # Get schema from SQLite
          KothariAPI::DB.conn.query("PRAGMA table_info(#{table_name})") do |rs|
            puts "[33mColumn Name          | Type    | Not Null | Default[0m"
            puts "-" * 60
            rs.each do
              cid = rs.read(Int32)
              col_name = rs.read(String)
              col_type = rs.read(String)
              not_null = rs.read(Int32) == 1
              default_val = rs.read(String?)
              pk = rs.read(Int32) == 1
              
              null_str = not_null ? "YES" : "NO"
              default_str = default_val || "NULL"
              pk_str = pk ? " [33m[PK][0m" : ""
              
              printf "%-20s | %-7s | %-8s | %s%s
", col_name, col_type, null_str, default_str, pk_str
            end
          end
          
          # Show record count
          KothariAPI::DB.conn.query("SELECT COUNT(*) FROM #{table_name}") do |rs|
            if rs.move_next
              count = rs.read(Int32)
              puts "
[33mTotal Records: [36m#{count}[0m"
            end
          end
        rescue ex
          puts "[31m✗ Error: #{ex.message}[0m"
        end
      else
        puts "[31m✗ Unknown model: #{name}[0m"
        puts "[33mAvailable models: #{KothariAPI::ModelRegistry.all_names.join(", ")}[0m"
      end
    elsif cmd.includes?(".where(")
      # Handle: Session.where("live = 1")
      name = cmd.split(".").first.strip.downcase
      condition_match = cmd.match(/.where(["'](.+?)["'])/)
      
      if condition_match
        condition = condition_match[1]
        if model = KothariAPI::ModelRegistry.lookup(name)
          begin
            results = model.where(condition)
            if results.empty?
              puts "[33m⚠ No records found matching: #{condition}[0m"
            else
              puts "[32m✓ Found #{results.size} record(s):[0m"
              pp results
            end
          rescue ex
            puts "[31m✗ Error: #{ex.message}[0m"
          end
        else
          puts "[31m✗ Unknown model: #{name}[0m"
        end
      else
        puts "\e[31m✗ Invalid .where() syntax. Use: Model.where(\"condition\")\e[0m"
      end
    elsif cmd.includes?(".find(")
      # Handle: Session.find(1)
      name = cmd.split(".").first.strip.downcase
      id_match = cmd.match(/.find((d+))/)
      
      if id_match
        id = id_match[1].to_i
        if model = KothariAPI::ModelRegistry.lookup(name)
          begin
            record = model.find(id)
            if record
              puts "[32m✓ Found record:[0m"
              pp record
            else
              puts "[33m⚠ No record found with id: #{id}[0m"
            end
          rescue ex
            puts "[31m✗ Error: #{ex.message}[0m"
          end
        else
          puts "[31m✗ Unknown model: #{name}[0m"
        end
      else
        puts "[31m✗ Invalid .find() syntax. Use: Model.find(id)[0m"
      end
    elsif cmd.ends_with?(".all")
      # Handle: Session.all, session.all
      name = cmd.split(".").first.strip.downcase
      
      if model = KothariAPI::ModelRegistry.lookup(name)
        begin
          results = model.all
          if results.empty?
            puts "[33m⚠ No records found.[0m"
          else
            puts "[32m✓ Found #{results.size} record(s):[0m"
            pp results
          end
        rescue ex
          puts "[31m✗ Error: #{ex.message}[0m"
        end
      else
        puts "[31m✗ Unknown model: #{name}[0m"
        puts "[33mAvailable models: #{KothariAPI::ModelRegistry.all_names.join(", ")}[0m"
      end
    else
      puts "[31m✗ Unknown command: #{cmd}[0m"
      puts "[33mType 'help' for a list of commands.[0m"
    end
  end
end