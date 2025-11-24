require "../kothari_api"

# Matrix-style intro animation
def show_intro(command_name : String)
  puts "\n\e[32m" # Green color
  puts "╔═══════════════════════════════════════════════════════════╗"
  puts "║                                                           ║"
  puts "║   ██╗  ██╗ ██████╗ ████████╗██╗  ██╗ █████╗ ██████╗ ██╗   ║"
  puts "║   ██║ ██╔╝██╔═══██╗╚══██╔══╝██║  ██║██╔══██╗██╔══██╗██║   ║"
  puts "║   █████╔╝ ██║   ██║   ██║   ███████║███████║██████╔╝██║   ║"
  puts "║   ██╔═██╗ ██║   ██║   ██║   ██╔══██║██╔══██║██╔══██╗██║   ║"
  puts "║   ██║  ██╗╚██████╔╝   ██║   ██║  ██║██║  ██║██║  ██║██║   ║"
  puts "║   ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝   ║"
  puts "║                                                           ║"
  puts "║              Rails-Style API Framework for Crystal        ║"
  puts "║                                                           ║"
  puts "╚═══════════════════════════════════════════════════════════╝"
  puts "\e[0m" # Reset color
  puts "\e[36m▶ #{command_name}\e[0m\n"
end

# ===============================================
# kothari new <app_name>
# ===============================================
if ARGV[0]? == "new"
  if ARGV[1]?.nil?
    show_intro("new")
    puts "\e[31m✗ Error: App name required\e[0m"
    puts "\e[33mUsage: kothari new <app_name>\e[0m\n"
    exit 1
  end

  app_name = ARGV[1]
  show_intro("new #{app_name}")
  puts "\e[36m⚡ Generating application structure...\e[0m"

  # Create structure
  system "mkdir -p #{app_name}/app/controllers"
  system "mkdir -p #{app_name}/app/models"
  system "mkdir -p #{app_name}/config"
  system "mkdir -p #{app_name}/src"
  system "mkdir -p #{app_name}/db/migrations"

  # shard.yml
  # New apps depend on the published GitHub shard, not a local path.
  File.write "#{app_name}/shard.yml", <<-YAML
name: #{app_name}
version: 0.1.0

dependencies:
  kothari_api:
    github: backlinkedclub/kothari_api
    version: ~> 0.1.0

targets:
  #{app_name}:
    main: src/server.cr
YAML

  # routes.cr
  File.write "#{app_name}/config/routes.cr", <<-ROUTES
KothariAPI::Router::Router.draw do |r|
  r.get "/", to: "home#index"
end
ROUTES

  # HomeController
  File.write "#{app_name}/app/controllers/home_controller.cr", <<-CTRL
class HomeController < KothariAPI::Controller
  # GET /
  # This is the default landing action for a new KothariAPI app.
  def index
    json({ message: "Welcome to KothariAPI" })
  end
end

KothariAPI::ControllerRegistry.register("home", HomeController)
CTRL

  # controllers auto-loader
  # Use a regular require glob so all controllers are pulled in.
  File.write "#{app_name}/app/controllers.cr", <<-LOAD
require "./controllers/*"
LOAD

  # models auto-loader
  # Like controllers, use a require glob so all models are loaded.
  File.write "#{app_name}/app/models.cr", <<-MODELS
require "./models/*"
MODELS

  # server.cr
  # Require the framework before app code so KothariAPI::Controller/Model, etc.
  # are defined when the controllers and models are loaded.
  File.write "#{app_name}/src/server.cr", <<-SRV
require "kothari_api"
require "../app/controllers"
require "../app/models"
require "../config/routes"
require "http/server"

# Auto-connect database
KothariAPI::DB.connect("db/development.sqlite3")

server = HTTP::Server.new do |context|
  begin
    method = context.request.method.to_s.upcase
    path = context.request.path
    route = KothariAPI::Router::Router.match(method, path)

    if route
      controller_class = KothariAPI::ControllerRegistry.lookup(route.controller)

      if controller_class
        controller = controller_class.new(context)
        controller.send(route.action)
      else
        context.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
        context.response.print({error: "Controller not found"}.to_json)
      end
    else
      context.response.status = HTTP::Status::NOT_FOUND
      context.response.print({error: "Not Found"}.to_json)
    end
  rescue ex
    STDERR.puts "Unhandled error: \#{ex.message}"
    ex.backtrace?.try &.each { |ln| STDERR.puts ln }
    context.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
    context.response.content_type = "application/json"
    context.response.print({error: "Internal Server Error"}.to_json)
  end
end

puts "Running on http://localhost:3000"
server.bind_tcp "0.0.0.0", 3000
server.listen
SRV

  # benchmark.cr
  # Performance benchmark script
  File.write "#{app_name}/benchmark.cr", <<-BENCH
require "http/client"
require "json"

# Simple benchmark script to test KothariAPI performance
class Benchmark
  @base_url : String
  @concurrent : Int32
  @requests : Int32

  def initialize(@base_url = "http://127.0.0.1:3000", @concurrent = 10, @requests = 1000)
  end

  def run
    puts "\n🚀 KothariAPI Performance Benchmark"
    puts "=" * 60
    puts "Concurrent connections: \#{@concurrent}"
    puts "Total requests: \#{@requests}"
    puts "=" * 60

    # Test 1: Simple GET request (home page)
    puts "\n📊 Test 1: GET / (Simple JSON response)"
    test_get("/", "GET /")

    puts "\n" + "=" * 60
    puts "✅ Benchmark complete!"
    puts "=" * 60
    puts "\n💡 Tip: Add more endpoints to test by editing benchmark.cr"
  end

  private def test_get(path : String, label : String)
    times = [] of Float64
    errors = 0

    start = Time.monotonic
    
    @requests.times do |i|
      begin
        req_start = Time.monotonic
        response = HTTP::Client.get("\#{@base_url}\#{path}")
        req_end = Time.monotonic
        
        if response.status_code == 200
          times << (req_end - req_start).total_milliseconds
        else
          errors += 1
        end
      rescue
        errors += 1
      end
    end

    elapsed = (Time.monotonic - start).total_seconds
    print_results(label, times, elapsed, errors)
  end

  private def test_post(path : String, data : Hash, label : String)
    times = [] of Float64
    errors = 0

    start = Time.monotonic
    
    @requests.times do |i|
      begin
        req_start = Time.monotonic
        response = HTTP::Client.post("\#{@base_url}\#{path}",
          headers: HTTP::Headers{"Content-Type" => "application/json"},
          body: data.merge({"title" => "\#{data["title"]} \#{i}"}).to_json)
        req_end = Time.monotonic
        
        if response.status_code == 201 || response.status_code == 200
          times << (req_end - req_start).total_milliseconds
        else
          errors += 1
        end
      rescue
        errors += 1
      end
    end

    elapsed = (Time.monotonic - start).total_seconds
    print_results(label, times, elapsed, errors)
  end

  private def print_results(label : String, times : Array(Float64), elapsed : Float64, errors : Int32)
    return if times.empty?
    
    times.sort!
    avg = times.sum / times.size
    min = times.first
    max = times.last
    p50 = times[times.size // 2]
    p95 = times[(times.size * 0.95).to_i]
    p99 = times[(times.size * 0.99).to_i]
    rps = times.size / elapsed

    puts "  Label: \#{label}"
    puts "  Requests: \#{times.size} (\#{errors} errors)"
    puts "  Duration: \#{elapsed.round(2)}s"
    puts "  Requests/sec: \#{rps.round(0)} req/s"
    puts "  Latency:"
    puts "    Min:    \#{min.round(2)}ms"
    puts "    Avg:    \#{avg.round(2)}ms"
    puts "    P50:    \#{p50.round(2)}ms"
    puts "    P95:    \#{p95.round(2)}ms"
    puts "    P99:    \#{p99.round(2)}ms"
    puts "    Max:    \#{max.round(2)}ms"
  end
end

# Run benchmark
benchmark = Benchmark.new(concurrent: 10, requests: 1000)
benchmark.run
BENCH

  # console.cr
  # Enhanced data console for inspecting models & running SQL.
  File.write "#{app_name}/console.cr", <<-CON
# Load framework and app code without starting the HTTP server
require "kothari_api"
require "./app/models"
require "./app/controllers"

# Connect to database (same as server does)
KothariAPI::DB.connect("db/development.sqlite3")

puts "\e[36m╔═══════════════════════════════════════════════════════════╗\e[0m"
puts "\e[36m║           KOTHARI API CONSOLE - DATA EXPLORER           ║\e[0m"
puts "\e[36m╚═══════════════════════════════════════════════════════════╝\e[0m"
puts "\e[33mType 'help' for commands, 'exit' to quit.\e[0m\n"

loop do
  print "\e[36mkothari>\e[0m "
  line = gets
  break if line.nil?
  cmd = line.strip
  break if cmd == "exit"

  case cmd
  when "help"
    puts "\e[32m╔═══════════════════════════════════════════════════════════╗\e[0m"
    puts "\e[32m║                    AVAILABLE COMMANDS                  ║\e[0m"
    puts "\e[32m╚═══════════════════════════════════════════════════════════╝\e[0m"
    puts ""
    puts "\e[33m📋 Model Commands:\e[0m"
    puts "  \e[36mmodels\e[0m                    - List all registered models"
    puts "  \e[36m<Model>.show\e[0m              - Show table structure (columns & types)"
    puts "  \e[36m<Model>.all\e[0m               - List all records (e.g. Session.all)"
    puts "  \e[36m<Model>.where(\\\"condition\\\")\e[0m - Query with WHERE clause (e.g. Session.where(\\\"live = 1\\\"))"
    puts "  \e[36m<Model>.find(id)\e[0m          - Find record by ID (e.g. Session.find(1))"
    puts ""
    puts "\e[33m🗄️  SQL Commands:\e[0m"
    puts "  \e[36msql SELECT ...\e[0m           - Run SELECT query"
    puts "  \e[36msql INSERT INTO ...\e[0m      - Insert new record"
    puts "  \e[36msql UPDATE ... SET ...\e[0m   - Update records"
    puts "  \e[36msql DELETE FROM ...\e[0m      - Delete records"
    puts "  \e[36msql CREATE TABLE ...\e[0m     - Create table"
    puts "  \e[36msql DROP TABLE ...\e[0m        - Drop table"
    puts "  \e[36msql .schema <table>\e[0m      - Show table schema"
    puts ""
    puts "\e[33m🔧 Utility:\e[0m"
    puts "  \e[36mexit\e[0m                      - Quit console"
    puts ""
  when "models"
    names = KothariAPI::ModelRegistry.all_names
    if names.empty?
      puts "\e[33m⚠ No models registered yet.\e[0m"
    else
      puts "\e[32m✓ Registered Models:\e[0m"
      names.each { |n| puts "  \e[36m• \#{n.capitalize}\e[0m" }
    end
  else
    if cmd.starts_with?("sql ")
      query = cmd[4..].strip
      if query.empty?
        puts "\e[31m✗ Error: SQL query cannot be empty\e[0m"
      else
        begin
          KothariAPI::DB.conn.query(query) do |rs|
            cols = rs.column_names
            if cols.empty?
              puts "\e[33m✓ Query executed successfully (no results)\e[0m"
            else
              # Print header
              header = cols.join(" | ")
              puts "\e[36m\#{header}\e[0m"
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
              puts "\e[33m✓ \#{count} row(s)\e[0m"
            end
          end
        rescue ex
          puts "\e[31m✗ SQL Error: \#{ex.message}\e[0m"
        end
      end
    elsif cmd.includes?(".show")
      # Handle: Session.show, session.show
      name = cmd.split(".").first.strip.downcase
      if model = KothariAPI::ModelRegistry.lookup(name)
        begin
          table_name = model.table
          puts "\e[32m╔═══════════════════════════════════════════════════════════╗\e[0m"
          puts "\e[32m║  Table: \e[36m\#{table_name}\e[32m\e[0m"
          puts "\e[32m╚═══════════════════════════════════════════════════════════╝\e[0m"
          
          # Get schema from SQLite
          KothariAPI::DB.conn.query("PRAGMA table_info(\#{table_name})") do |rs|
            puts "\e[33mColumn Name          | Type    | Not Null | Default\e[0m"
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
              pk_str = pk ? " \e[33m[PK]\e[0m" : ""
              
              printf "%-20s | %-7s | %-8s | %s%s\n", col_name, col_type, null_str, default_str, pk_str
            end
          end
          
          # Show record count
          KothariAPI::DB.conn.query("SELECT COUNT(*) FROM \#{table_name}") do |rs|
            if rs.move_next
              count = rs.read(Int32)
              puts "\n\e[33mTotal Records: \e[36m\#{count}\e[0m"
            end
          end
        rescue ex
          puts "\e[31m✗ Error: \#{ex.message}\e[0m"
        end
      else
        puts "\e[31m✗ Unknown model: \#{name}\e[0m"
        puts "\e[33mAvailable models: \#{KothariAPI::ModelRegistry.all_names.join(", ")}\e[0m"
      end
    elsif cmd.includes?(".where(")
      # Handle: Session.where("live = 1")
      name = cmd.split(".").first.strip.downcase
      condition_match = cmd.match(/\.where\(["'](.+?)["']\)/)
      
      if condition_match
        condition = condition_match[1]
        if model = KothariAPI::ModelRegistry.lookup(name)
          begin
            results = model.where(condition)
            if results.empty?
              puts "\e[33m⚠ No records found matching: \#{condition}\e[0m"
            else
              puts "\e[32m✓ Found \#{results.size} record(s):\e[0m"
              pp results
            end
          rescue ex
            puts "\e[31m✗ Error: \#{ex.message}\e[0m"
          end
        else
          puts "\e[31m✗ Unknown model: \#{name}\e[0m"
        end
      else
        puts "\e[31m✗ Invalid .where() syntax. Use: Model.where(\"condition\")\e[0m"
      end
    elsif cmd.includes?(".find(")
      # Handle: Session.find(1)
      name = cmd.split(".").first.strip.downcase
      id_match = cmd.match(/\.find\((\d+)\)/)
      
      if id_match
        id = id_match[1].to_i
        if model = KothariAPI::ModelRegistry.lookup(name)
          begin
            record = model.find(id)
            if record
              puts "\e[32m✓ Found record:\e[0m"
              pp record
            else
              puts "\e[33m⚠ No record found with id: \#{id}\e[0m"
            end
          rescue ex
            puts "\e[31m✗ Error: \#{ex.message}\e[0m"
          end
        else
          puts "\e[31m✗ Unknown model: \#{name}\e[0m"
        end
      else
        puts "\e[31m✗ Invalid .find() syntax. Use: Model.find(id)\e[0m"
      end
    elsif cmd.ends_with?(".all")
      # Handle: Session.all, session.all
      name = cmd.split(".").first.strip.downcase
      
      if model = KothariAPI::ModelRegistry.lookup(name)
        begin
          results = model.all
          if results.empty?
            puts "\e[33m⚠ No records found.\e[0m"
          else
            puts "\e[32m✓ Found \#{results.size} record(s):\e[0m"
            pp results
          end
        rescue ex
          puts "\e[31m✗ Error: \#{ex.message}\e[0m"
        end
      else
        puts "\e[31m✗ Unknown model: \#{name}\e[0m"
        puts "\e[33mAvailable models: \#{KothariAPI::ModelRegistry.all_names.join(", ")}\e[0m"
      end
    else
      puts "\e[31m✗ Unknown command: \#{cmd}\e[0m"
      puts "\e[33mType 'help' for a list of commands.\e[0m"
    end
  end
end
CON

  puts "\e[32m✓\e[0m Application \e[36m#{app_name}\e[0m created successfully!"
  puts "\n\e[33m▶ Next steps:\e[0m"
  puts "  \e[36mcd #{app_name}\e[0m"
  puts "  \e[36mshards install\e[0m"
  puts "  \e[36mkothari server\e[0m"
  puts "\n\e[32mHappy coding! 🚀\e[0m\n"
  exit 0
end

# ===============================================
# kothari server
# ===============================================
if ARGV[0]? == "server"
  system "crystal run src/server.cr"
  exit 0
end

# ------------------------------------------
# kothari g controller <name>
# ------------------------------------------
if ARGV[0]? == "g" && ARGV[1]? == "controller"
  if ARGV[2]?.nil?
    puts "Usage: kothari g controller <name>"
    exit 1
  end

  name       = ARGV[2].downcase
  class_name = name.camelcase

  controller_path = "app/controllers/#{name}_controller.cr"
  routes_path     = "config/routes.cr"

  # Create controller file
  File.write controller_path, <<-CTRL
class #{class_name}Controller < KothariAPI::Controller
  # GET /#{name}
  # TODO: implement this action. For example, you might render a list
  # of records or some static JSON.
  def index
    json({ message: "#{class_name}#index" })
  end
end

KothariAPI::ControllerRegistry.register("#{name}", #{class_name}Controller)
CTRL

  # Read routes file
  routes = File.read(routes_path).lines

  # Find the last "end"
  end_index = routes.rindex { |l| l.strip == "end" }

  if end_index.nil?
    # No `end`? Just append at bottom
    File.open(routes_path, "a") do |f|
      f.puts "  r.get \"/#{name}\", to: \"#{name}#index\""
    end
  else
    # Insert route BEFORE last end
    routes.insert(end_index, "  r.get \"/#{name}\", to: \"#{name}#index\"")
    # `String#lines` strips newlines, so re-join with "\n" and add a
    # trailing newline to keep the file nicely formatted.
    File.write(routes_path, routes.join("\n") + "\n")
  end

  show_intro("generate controller #{name}")
  puts "\e[32m✓\e[0m Created controller \e[36m#{class_name}Controller\e[0m"
  puts "\e[32m✓\e[0m Added route \e[33mGET /#{name}\e[0m"
  puts "\e[36m\n▶ Next: Add actions to app/controllers/#{name}_controller.cr\e[0m\n"
  exit 0
end

# ===============================================
# kothari g migration
# ===============================================
if ARGV[0]? == "g" && ARGV[1]? == "migration"
  if ARGV[2]?.nil?
    puts "Usage: kothari g migration <name> field:type field:type ..."
    exit 1
  end

  name = ARGV[2]
  timestamp = Time.utc.to_unix_ms.to_s
  filename = "db/migrations/#{timestamp}_#{name}.sql"

  fields = ARGV[3..] || [] of String

  columns_sql = fields.map do |f|
    key, type = f.split(":")
    "#{key} #{type.upcase}"
  end.join(", ")

  # Add timestamps to all tables
  timestamp_columns = ",\n  created_at TEXT DEFAULT CURRENT_TIMESTAMP,\n  updated_at TEXT DEFAULT CURRENT_TIMESTAMP"
  
  File.write filename, <<-SQL
CREATE TABLE IF NOT EXISTS #{name} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  #{columns_sql}#{timestamp_columns}
);
SQL

  show_intro("generate migration #{name}")
  puts "\e[32m✓\e[0m Created migration: \e[36m#{filename}\e[0m"
  puts "\e[36m\n▶ Next: Run \e[33mkothari db:migrate\e[36m to apply migrations\e[0m\n"
  exit 0
end

# ===============================================
# kothari db:migrate
# ===============================================
if ARGV[0]? == "db:migrate"
  show_intro("db:migrate")
  puts "\e[36m⚡ Connecting to database...\e[0m"
  KothariAPI::DB.connect("db/development.sqlite3")
  puts "\e[36m⚡ Running migrations...\e[0m"
  KothariAPI::Migrator.migrate
  puts "\e[32m✓ Migrations complete.\e[0m\n"
  exit 0
end

# ===============================================
# kothari db:reset
# ===============================================
if ARGV[0]? == "db:reset"
  show_intro("db:reset")
  db_path = "db/development.sqlite3"

  if File.exists?(db_path)
    puts "\e[36m⚡ Removing database #{db_path}...\e[0m"
    File.delete(db_path)
  else
    puts "\e[33m⚠ No existing database at #{db_path}, creating fresh.\e[0m"
  end

  puts "\e[36m⚡ Recreating database and running migrations...\e[0m"
  KothariAPI::DB.connect(db_path)
  KothariAPI::Migrator.migrate

  puts "\e[32m✓ Database reset complete.\e[0m\n"
  exit 0
end

# ===============================================
# kothari g model <name>
# ===============================================
if ARGV[0]? == "g" && ARGV[1]? == "model"
  if ARGV[2]?.nil?
    puts "Usage: kothari g model <name> field:type field:type ..."
    exit 1
  end

  name = ARGV[2].downcase
  class_name = name.camelcase

  fields = ARGV[3..] || [] of String

  ivars = fields.map do |f|
    key, type = f.split(":")
    crystal_type = case type.downcase
                   when "string", "text"   then "String"
                   when "int", "integer"   then "Int32"
                   when "bigint", "int64"  then "Int64"
                   when "float", "double"  then "Float64"
                   when "bool", "boolean"  then "Bool"
                   else
                     type.camelcase
                   end
    "@#{key} : #{crystal_type}"
  end.join("\n  ")

  ctor_args = fields.map do |f|
    key, type = f.split(":")
    crystal_type = case type.downcase
                   when "string", "text"   then "String"
                   when "int", "integer"   then "Int32"
                   when "bigint", "int64"  then "Int64"
                   when "float", "double"  then "Float64"
                   when "bool", "boolean"  then "Bool"
                   else
                     type.camelcase
                   end
    "@#{key} : #{crystal_type}"
  end.join(", ")

  system "mkdir -p app/models"

  # Add timestamp fields to scaffold model
  timestamp_ivars = "\n  @created_at : String?\n  @updated_at : String?"
  timestamp_args = ", @created_at : String? = nil, @updated_at : String? = nil"
  
  File.write "app/models/#{name}.cr", <<-MODEL
class #{class_name} < KothariAPI::Model
  table "#{name}s"

  #{ivars}#{timestamp_ivars}

  #{fields.empty? ? "" : "def initialize(#{ctor_args}#{timestamp_args})\n  end"}

  # NOTE: This model is registered so tools like `kothari console`
  # can discover it by name.
  KothariAPI::ModelRegistry.register("#{name}", #{class_name})
end
MODEL

  show_intro("generate model #{name}")
  puts "\e[32m✓\e[0m Created model \e[36m#{class_name}\e[0m"
  puts "\e[36m\n▶ Next: Run \e[33mkothari g migration create_#{name}s\e[36m to create the table\e[0m\n"
  exit 0
end

# ===============================================
# kothari g auth <name>
# ===============================================
if ARGV[0]? == "g" && ARGV[1]? == "auth"
  name = (ARGV[2]? || "user").downcase
  class_name = name.camelcase

  model_path      = "app/models/#{name}.cr"
  migration_ts    = Time.utc.to_unix_ms.to_s
  migration_name  = "create_#{name}s"
  migration_path  = "db/migrations/#{migration_ts}_#{migration_name}.sql"
  controller_path = "app/controllers/auth_controller.cr"
  routes_path     = "config/routes.cr"

  system "mkdir -p app/models"
  system "mkdir -p app/controllers"
  system "mkdir -p db/migrations"

  # User model with secure password
  File.write model_path, <<-MODEL
class #{class_name} < KothariAPI::Model
  table "#{name}s"

  include KothariAPI::Auth::Password

  @email : String
  @password_digest : String
  @created_at : String?
  @updated_at : String?

  def initialize(@email : String, @password_digest : String, @created_at : String? = nil, @updated_at : String? = nil)
  end

  KothariAPI::ModelRegistry.register("#{name}", #{class_name})
end
MODEL

  # Migration for users table
  File.write migration_path, <<-SQL
CREATE TABLE IF NOT EXISTS #{name}s (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL,
  password_digest TEXT NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
SQL

  # Auth controller with signup/login using JWT
  File.write controller_path, <<-CTRL
class AuthController < KothariAPI::Controller
  # POST /signup
  def signup
    data = json_body
    email = data["email"]?.try &.to_s
    password = data["password"]?.try &.to_s

    unless email && password
      context.response.status = HTTP::Status::BAD_REQUEST
      return json({error: "email and password are required"})
    end

    # Very simple duplicate check
    existing = #{class_name}.find_by("email", email)
    if existing
      context.response.status = HTTP::Status::CONFLICT
      return json({error: "Email already taken"})
    end

    digest = KothariAPI::Auth::Password.hash(password.not_nil!)
    user = #{class_name}.create(
      email: email.not_nil!,
      password_digest: digest
    )

    token = KothariAPI::Auth::JWTAuth.issue_simple({"email" => email.not_nil!})
    context.response.status = HTTP::Status::CREATED
    json({token: token, email: email.not_nil!})
  end

  # POST /login
  def login
    data = json_body
    email = data["email"]?.try &.to_s
    password = data["password"]?.try &.to_s

    unless email && password
      context.response.status = HTTP::Status::BAD_REQUEST
      return json({error: "email and password are required"})
    end

    user = #{class_name}.find_by("email", email.not_nil!)

    unless user && KothariAPI::Auth::Password.verify(password.not_nil!, user.password_digest.not_nil!)
      context.response.status = HTTP::Status::UNAUTHORIZED
      return json({error: "Invalid email or password"})
    end

    token = KothariAPI::Auth::JWTAuth.issue_simple({"email" => email.not_nil!})
    json({token: token, email: email.not_nil!})
  end
end

KothariAPI::ControllerRegistry.register("auth", AuthController)
CTRL

  # Ensure controllers and models autoloaders exist
  system "mkdir -p app"

  unless File.exists?("app/controllers.cr")
    File.write "app/controllers.cr", <<-LOAD
require "kothari_api"
require "./controllers/*"
LOAD
  end

  unless File.exists?("app/models.cr")
    File.write "app/models.cr", <<-MODELS
require "./models/*"
MODELS
  end

  # Add auth routes
  routes = File.read(routes_path).lines
  end_index = routes.rindex { |l| l.strip == "end" }

  new_lines = [
    "  r.post \"/signup\", to: \"auth#signup\"",
    "  r.post \"/login\", to: \"auth#login\"",
  ]

  if end_index
    new_lines.reverse_each do |line|
      routes.insert(end_index, line)
    end
    File.write(routes_path, routes.join("\n") + "\n")
  else
    File.open(routes_path, "a") do |f|
      new_lines.each { |line| f.puts line }
    end
  end

  show_intro("generate auth #{name}")
  puts "\e[32m✓\e[0m Created auth model \e[36m#{class_name}\e[0m"
  puts "\e[32m✓\e[0m Created \e[36mAuthController\e[0m with /signup and /login"
  puts "\e[32m✓\e[0m Added routes \e[33mPOST /signup\e[0m and \e[33mPOST /login\e[0m"
  puts "\e[36m\n▶ Next: Run \e[33mkothari db:migrate\e[36m then use /signup and /login\e[0m\n"
  exit 0
end

# ===============================================
# kothari g scaffold <name> field:type ...
# ===============================================
if ARGV[0]? == "g" && ARGV[1]? == "scaffold"
  if ARGV[2]?.nil?
    puts "Usage: kothari g scaffold <name> field:type field:type ..."
    exit 1
  end

  raw_name = ARGV[2].downcase

  # Treat the argument as a resource name. If it already ends with "s"
  # (e.g. "students"), use that as the plural and derive a singular by
  # dropping the trailing "s". Otherwise, make the plural by adding "s".
  singular = raw_name.ends_with?("s") ? raw_name[0...-1] : raw_name
  plural   = raw_name.ends_with?("s") ? raw_name          : "#{raw_name}s"

  class_name          = singular.camelcase   # e.g. "Student"
  controller_klass    = "#{plural.camelcase}Controller" # e.g. "StudentsController"
  model_file_name     = singular                      # e.g. "student.cr"
  controller_file_name = "#{plural}_controller"       # e.g. "students_controller.cr"

  fields = ARGV[3..] || [] of String

  # 1) Model - Fix type mapping to ensure Int32 and String
  model_ivars = fields.map do |f|
    key, type = f.split(":")
    crystal_type = case type.downcase
                   when "string", "text"   then "String"
                   when "int", "integer"    then "Int32"
                   when "bigint", "int64"   then "Int64"
                   when "float", "double"   then "Float64"
                   when "bool", "boolean"   then "Bool"
                   else
                     "String"  # Default to String for unknown types
                   end
    "@#{key} : #{crystal_type}"
  end.join("\n  ")

  model_ctor_args = fields.map do |f|
    key, type = f.split(":")
    crystal_type = case type.downcase
                   when "string", "text"   then "String"
                   when "int", "integer"    then "Int32"
                   when "bigint", "int64"   then "Int64"
                   when "float", "double"   then "Float64"
                   when "bool", "boolean"   then "Bool"
                   else
                     "String"  # Default to String for unknown types
                   end
    "@#{key} : #{crystal_type}"
  end.join(", ")

  system "mkdir -p app/models"

  # Add timestamp fields to model
  timestamp_ivars = "\n  @created_at : String?\n  @updated_at : String?"
  timestamp_args = ", @created_at : String? = nil, @updated_at : String? = nil"
  
  # Generate property declarations for all fields
  model_properties = fields.map do |f|
    key, type = f.split(":")
    crystal_type = case type.downcase
                   when "string", "text"   then "String"
                   when "int", "integer"    then "Int32"
                   when "bigint", "int64"   then "Int64"
                   when "float", "double"   then "Float64"
                   when "bool", "boolean"   then "Bool"
                   else
                     "String"
                   end
    "property #{key} : #{crystal_type}"
  end.join("\n  ")
  timestamp_properties = "\n  property created_at : String?\n  property updated_at : String?"
  
  File.write "app/models/#{model_file_name}.cr", <<-MODEL
class #{class_name} < KothariAPI::Model
  table "#{plural}"

  #{model_ivars}#{timestamp_ivars}

  #{model_properties}#{timestamp_properties}

  #{fields.empty? ? "" : "def initialize(#{model_ctor_args}#{timestamp_args})\n  end"}

  KothariAPI::ModelRegistry.register("#{singular}", #{class_name})
end
MODEL

  # 2) Migration
  timestamp = Time.utc.to_unix_ms.to_s
  mig_filename = "db/migrations/#{timestamp}_create_#{plural}.sql"

  columns_sql = fields.map do |f|
    key, type = f.split(":")
    "#{key} #{type.upcase}"
  end.join(",\n  ")

  # Add timestamps to all tables
  timestamp_columns = ",\n  created_at TEXT DEFAULT CURRENT_TIMESTAMP,\n  updated_at TEXT DEFAULT CURRENT_TIMESTAMP"
  
  File.write mig_filename, <<-SQL
CREATE TABLE IF NOT EXISTS #{plural} (
  id INTEGER PRIMARY KEY AUTOINCREMENT#{fields.empty? ? "" : ",\n  " + columns_sql}#{timestamp_columns}
);
SQL

  # 3) Controller
  controller_path = "app/controllers/#{controller_file_name}.cr"
  routes_path     = "config/routes.cr"

  File.write controller_path, <<-CTRL
class #{controller_klass} < KothariAPI::Controller
  # GET /#{plural}
  # Lists all #{class_name} records as JSON.
  def index
    json(#{class_name}.all)
  end

  # GET /#{plural}/:id
  # NOTE: Path params are not yet wired; you can fetch by query param
  # e.g. /#{name}s?id=1 for now.
  def show
    id = params["id"]?.try &.to_i?
    if id && (record = #{class_name}.find(id))
      json(record)
    else
      context.response.status = HTTP::Status::NOT_FOUND
      json({ error: "Not Found" })
    end
  end

  # POST /#{name}s
  # Creates a new #{class_name} from JSON body using strong params.
  def create
    attrs = #{singular}_params
    record = #{class_name}.create(
      #{fields.map do |f|
          key, type = f.split(":")
          crystal_type = case type.downcase
                         when "int", "integer" then "attrs[\"#{key}\"].as_i? || attrs[\"#{key}\"].to_s.to_i"
                         when "bigint", "int64" then "attrs[\"#{key}\"].as_i64? || attrs[\"#{key}\"].to_s.to_i64"
                         when "float", "double" then "attrs[\"#{key}\"].as_f? || attrs[\"#{key}\"].to_s.to_f"
                         when "bool", "boolean" then "attrs[\"#{key}\"].as_bool? || attrs[\"#{key}\"].to_s == \"true\""
                         else
                           "attrs[\"#{key}\"].to_s"
                         end
          "#{key}: #{crystal_type}"
        end.join(",\n      ")}
    )

    context.response.status = HTTP::Status::CREATED
    json(record)
  end

  # PATCH/PUT /#{plural}/:id
  # TODO: Implement update by id (e.g. with raw SQL).
  def update
    json({ message: "update not implemented yet" })
  end

  # DELETE /#{plural}/:id
  # TODO: Implement destroy by id.
  def destroy
    json({ message: "destroy not implemented yet" })
  end

  private def #{singular}_params
    # Strong params example – only allow the whitelisted keys from
    # the JSON request body.
    permit_body(
      #{fields.map { |f| key, _t = f.split(":"); "\"#{key}\"" }.join(", ")}
    )
  end
end

KothariAPI::ControllerRegistry.register("#{plural}", #{controller_klass})
CTRL

  # 4) Routes - Fix formatting issues and ensure proper newlines
  routes_path = "config/routes.cr"
  routes_content = File.read(routes_path)
  
  # Check if routes already exist to avoid duplicates
  if routes_content.includes?("/#{plural}")
    # Routes already added, skip
  else
    # Fix malformed routes (all on one line) by completely rewriting
    if routes_content.includes?("do |r|") && !routes_content.includes?("\n  r.get")
      # Routes are malformed - extract all routes and rebuild
      header = "KothariAPI::Router::Router.draw do |r|\n"
      footer = "end\n"
      
      # Extract all route calls using regex
      route_matches = routes_content.scan(/r\.(get|post|put|patch|delete)\s+"([^"]+)",\s+to:\s+"([^"]+)"/)
      
      # Build new properly formatted content
      new_content = header
      route_matches.each do |match|
        method, path, controller_action = match[1], match[2], match[3]
        new_content += "  r.#{method} \"#{path}\", to: \"#{controller_action}\"\n"
      end
      # Add new routes
      new_content += "  r.get \"/#{plural}\", to: \"#{plural}#index\"\n"
      new_content += "  r.post \"/#{plural}\", to: \"#{plural}#create\"\n"
      new_content += footer
      
      File.write(routes_path, new_content)
    else
      # Routes are properly formatted, just add new ones
      lines = routes_content.lines
      end_index = lines.rindex { |l| l.strip == "end" }
      
      resource_lines = [
        "  r.get \"/#{plural}\", to: \"#{plural}#index\"",
        "  r.post \"/#{plural}\", to: \"#{plural}#create\"",
      ]
      
      if end_index.nil?
        # No end found, append to file
        File.open(routes_path, "a") do |f|
          resource_lines.each { |line| f.puts line }
          f.puts "end"
        end
      else
        # Insert before the last "end"
        resource_lines.reverse_each do |line|
          lines.insert(end_index, line)
        end
        # Write back with proper newlines
        File.write(routes_path, lines.join("\n") + "\n")
      end
    end
  end

  show_intro("generate scaffold #{raw_name}")
  puts "\e[32m✓\e[0m Scaffolded \e[36m#{class_name}\e[0m:"
  puts "  \e[32m•\e[0m Model \e[36mapp/models/#{model_file_name}.cr\e[0m"
  puts "  \e[32m•\e[0m Migration \e[36m#{mig_filename}\e[0m"
  puts "  \e[32m•\e[0m Controller \e[36mapp/controllers/#{controller_file_name}.cr\e[0m"
  puts "  \e[32m•\e[0m Routes for \e[33m/#{plural}\e[0m"
  puts "\n\e[33m▶ Next steps:\e[0m"
  puts "  \e[36mkothari db:migrate\e[0m"
  puts "  \e[36mkothari server\e[0m"
  puts "\n\e[32mReady to go! 🚀\e[0m\n"
  exit 0
end

# ===============================================
# kothari console
# ===============================================
if ARGV[0]? == "console"
  # Delegate to the app's console entrypoint which we generated as
  # `console.cr` in the app root.
  if File.exists?("console.cr")
    system "crystal run console.cr"
  else
    puts "No console.cr found. Are you in a KothariAPI app directory?"
  end
  exit 0
end

# ===============================================
# kothari benchmark
# ===============================================
if ARGV[0]? == "benchmark"
  show_intro("benchmark")
  
  # Check if we're in a KothariAPI app
  unless File.exists?("src/server.cr")
    puts "\e[31m✗ Error: Not in a KothariAPI app directory\e[0m"
    puts "\e[33mMake sure you're in your app's root directory (where src/server.cr exists)\e[0m\n"
    exit 1
  end

  # Create benchmark.cr if it doesn't exist
  unless File.exists?("benchmark.cr")
    puts "\e[33m⚠ benchmark.cr not found. Creating it...\e[0m"
    File.write "benchmark.cr", <<-BENCH
require "http/client"
require "json"

# Simple benchmark script to test KothariAPI performance
class Benchmark
  @base_url : String
  @concurrent : Int32
  @requests : Int32

  def initialize(@base_url = "http://127.0.0.1:3000", @concurrent = 10, @requests = 1000)
  end

  def run
    puts "\n🚀 KothariAPI Performance Benchmark"
    puts "=" * 60
    puts "Concurrent connections: \#{@concurrent}"
    puts "Total requests: \#{@requests}"
    puts "=" * 60

    # Test 1: Simple GET request (home page)
    puts "\n📊 Test 1: GET / (Simple JSON response)"
    test_get("/", "GET /")

    puts "\n" + "=" * 60
    puts "✅ Benchmark complete!"
    puts "=" * 60
    puts "\n💡 Tip: Add more endpoints to test by editing benchmark.cr"
  end

  private def test_get(path : String, label : String)
    times = [] of Float64
    errors = 0

    start = Time.monotonic
    
    @requests.times do |i|
      begin
        req_start = Time.monotonic
        response = HTTP::Client.get("\#{@base_url}\#{path}")
        req_end = Time.monotonic
        
        if response.status_code == 200
          times << (req_end - req_start).total_milliseconds
        else
          errors += 1
        end
      rescue
        errors += 1
      end
    end

    elapsed = (Time.monotonic - start).total_seconds
    print_results(label, times, elapsed, errors)
  end

  private def test_post(path : String, data : Hash, label : String)
    times = [] of Float64
    errors = 0

    start = Time.monotonic
    
    @requests.times do |i|
      begin
        req_start = Time.monotonic
        response = HTTP::Client.post("\#{@base_url}\#{path}",
          headers: HTTP::Headers{"Content-Type" => "application/json"},
          body: data.merge({"title" => "\#{data["title"]} \#{i}"}).to_json)
        req_end = Time.monotonic
        
        if response.status_code == 201 || response.status_code == 200
          times << (req_end - req_start).total_milliseconds
        else
          errors += 1
        end
      rescue
        errors += 1
      end
    end

    elapsed = (Time.monotonic - start).total_seconds
    print_results(label, times, elapsed, errors)
  end

  private def print_results(label : String, times : Array(Float64), elapsed : Float64, errors : Int32)
    return if times.empty?
    
    times.sort!
    avg = times.sum / times.size
    min = times.first
    max = times.last
    p50 = times[times.size // 2]
    p95 = times[(times.size * 0.95).to_i]
    p99 = times[(times.size * 0.99).to_i]
    rps = times.size / elapsed

    puts "  Label: \#{label}"
    puts "  Requests: \#{times.size} (\#{errors} errors)"
    puts "  Duration: \#{elapsed.round(2)}s"
    puts "  Requests/sec: \#{rps.round(0)} req/s"
    puts "  Latency:"
    puts "    Min:    \#{min.round(2)}ms"
    puts "    Avg:    \#{avg.round(2)}ms"
    puts "    P50:    \#{p50.round(2)}ms"
    puts "    P95:    \#{p95.round(2)}ms"
    puts "    P99:    \#{p99.round(2)}ms"
    puts "    Max:    \#{max.round(2)}ms"
  end
end

# Run benchmark
benchmark = Benchmark.new(concurrent: 10, requests: 1000)
benchmark.run
BENCH
    puts "\e[32m✓\e[0m Created \e[36mbenchmark.cr\e[0m\n"
  end

  # Check if server is running
  puts "\e[36m⚡ Checking if server is running...\e[0m"
  server_running = false
  begin
    client = HTTP::Client.new("127.0.0.1", 3000)
    client.connect_timeout = 1.second
    response = client.get("/")
    server_running = true if response.status_code == 200
    client.close
  rescue
    server_running = false
  end

  unless server_running
    puts "\e[31m✗ Server is not running on http://127.0.0.1:3000\e[0m"
    puts "\e[33mPlease start the server first:\e[0m"
    puts "  \e[36mkothari server\e[0m"
    puts "\n\e[33mThen run the benchmark in another terminal:\e[0m"
    puts "  \e[36mkothari benchmark\e[0m\n"
    exit 1
  end

  puts "\e[32m✓\e[0m Server is running\n"
  puts "\e[36m⚡ Running benchmark...\e[0m\n"

  # Run the benchmark
  system "crystal run benchmark.cr"
  exit 0
end

# ===============================================
# kothari help (or just kothari)
# ===============================================
if ARGV[0]? == "help" || ARGV.empty?
  show_intro("help")

puts "\e[36mAvailable Commands:\e[0m\n"
puts "  \e[33mnew\e[0m \e[90m<app_name>\e[0m"
puts "     Create a new KothariAPI application"
puts ""
puts "  \e[33mserver\e[0m"
puts "     Start the development server"
puts ""
puts "  \e[33mbenchmark\e[0m"
puts "     Run performance benchmarks"
puts ""
puts "  \e[33mg controller\e[0m \e[90m<name>\e[0m"
puts "     Generate a new controller"
puts ""
puts "  \e[33mg model\e[0m \e[90m<name>\e[0m \e[90m[field:type ...]\e[0m"
puts "     Generate a new model with optional fields"
puts ""
puts "  \e[33mg migration\e[0m \e[90m<name>\e[0m \e[90m[field:type ...]\e[0m"
puts "     Generate a new database migration"
puts ""
puts "  \e[33mdb:migrate\e[0m"
puts "     Run pending database migrations"
puts ""
puts "  \e[33mdb:reset\e[0m"
puts "     Drop, create, and migrate the database"
puts ""
puts "  \e[33mg scaffold\e[0m \e[90m<name>\e[0m \e[90m[field:type ...]\e[0m"
puts "     Generate model, controller, and routes"
puts ""
puts "  \e[33mg auth\e[0m \e[90m[name]\e[0m"
puts "     Generate authentication (User model, AuthController, routes)"
puts ""
puts "  \e[33mconsole\e[0m"
puts "     Open an interactive console"
puts ""
puts "\e[32mFor more information, visit: https://github.com/kothari-api\e[0m"
puts "\e[90mVersion: 1.0.0\e[0m\n"
  exit 0
end
