require "../kothari_api"

# Matrix-style intro animation with dynamic command name
def show_intro(command_name : String)
  # Extract the main command word from command_name
  # Special case: "new" command should show "KOTHARI" instead of "NEW"
  # e.g., "db:migrate" -> "MIGRATE", "generate scaffold post" -> "SCAFFOLD", "new myapp" -> "KOTHARI"
  parts = command_name.split
  main_command = if parts.size > 0 && parts[0] == "new"
    # For "new" command, always show "KOTHARI"
    "KOTHARI"
  elsif parts.size > 1 && parts[0] == "generate"
    # For "generate scaffold post" -> "SCAFFOLD"
    parts[1].upcase
  elsif command_name.includes?(":")
    # For "db:migrate" -> "MIGRATE"
    split_parts = command_name.split(":")
    split_parts.size > 1 ? split_parts[1].upcase : command_name.upcase
  else
    # For "routes", etc. -> use first word
    parts.size > 0 ? parts[0].upcase : command_name.upcase
  end
  
  # Clean up the command name (remove non-alphanumeric, limit length)
  display_text = main_command.gsub(/[^A-Z0-9]/, "")
  if display_text.size > 8
    display_text = display_text[0, 8]
  end
  if display_text.empty?
    display_text = "KOTHARI"
  end
  
  puts "\n\e[32m" # Green color
  puts "╔═══════════════════════════════════════════════════════════╗"
  puts "║                                                           ║"
  
  # Use the original KOTHARI ASCII art pattern but replace with command name
  # The original pattern has 6 lines, each 59 chars wide (including borders)
  # We'll create a similar pattern for the command name
  
  # Professional box-drawing ASCII art (6 lines each, consistent width 7 chars)
  # Each letter is clearly recognizable and properly formed
  ascii_chars = {
    'A' => [" ████  ", "██  ██ ", "██████ ", "██  ██ ", "██  ██ ", "██  ██ "],
    'B' => ["█████  ", "██  ██ ", "█████  ", "██  ██ ", "██  ██ ", "█████  "],
    'C' => [" █████ ", "██     ", "██     ", "██     ", "██     ", " █████ "],
    'D' => ["█████  ", "██  ██ ", "██  ██ ", "██  ██ ", "██  ██ ", "█████  "],
    'E' => ["██████ ", "██     ", "█████  ", "██     ", "██     ", "██████ "],
    'F' => ["██████ ", "██     ", "█████  ", "██     ", "██     ", "██     "],
    'G' => [" █████ ", "██     ", "██     ", "██  ███", "██   ██", " █████ "],
    'H' => ["██  ██ ", "██  ██ ", "██████ ", "██  ██ ", "██  ██ ", "██  ██ "],
    'I' => ["██████ ", "  ██   ", "  ██   ", "  ██   ", "  ██   ", "██████ "],
    'J' => ["██████ ", "    ██ ", "    ██ ", "    ██ ", "██  ██ ", " ████  "],
    'K' => ["██  ██ ", "██ ██  ", "████   ", "██ ██  ", "██ ██  ", "██  ██ "],
    'L' => ["██     ", "██     ", "██     ", "██     ", "██     ", "██████ "],
    'M' => ["██   ██", "███ ███", "███████", "██ █ ██", "██   ██", "██   ██"],
    'N' => ["██   ██", "███  ██", "████ ██", "██ ████", "██  ███", "██   ██"],
    'O' => [" █████ ", "██   ██", "██   ██", "██   ██", "██   ██", " █████ "],
    'P' => ["█████  ", "██  ██ ", "██  ██ ", "█████  ", "██     ", "██     "],
    'Q' => [" █████ ", "██   ██", "██   ██", "██ █ ██", "██  ███", " ██████"],
    'R' => ["█████  ", "██  ██ ", "██  ██ ", "█████  ", "██  ██ ", "██   ██"],
    'S' => [" ██████", "██     ", "██     ", " █████ ", "     ██", "██████ "],
    'T' => ["███████", "   ██  ", "   ██  ", "   ██  ", "   ██  ", "   ██  "],
    'U' => ["██   ██", "██   ██", "██   ██", "██   ██", "██   ██", " █████ "],
    'V' => ["██   ██", "██   ██", "██   ██", "██   ██", " ██ ██ ", "  ███  "],
    'W' => ["██   ██", "██   ██", "██   ██", "██ █ ██", "███████", "███ ███"],
    'X' => ["██   ██", " ██ ██ ", "  ███  ", "  ███  ", " ██ ██ ", "██   ██"],
    'Y' => ["██   ██", " ██ ██ ", "  ███  ", "   ██  ", "   ██  ", "   ██  "],
    'Z' => ["███████", "     ██", "    ██ ", "   ██  ", "  ██   ", "███████"],
  }
  
  # Generate 6 lines of clean ASCII art with proper spacing
  6.times do |line_idx|
    line = "║"
    # Center the text by calculating padding
    total_char_width = display_text.size * 7  # Each char is 7 chars wide
    padding_val = ((59 - total_char_width) / 2).to_i
    padding_val = padding_val > 3 ? padding_val : 3
    line += " " * padding_val
    
    display_text.chars.each do |char|
      if ascii_chars.has_key?(char)
        pattern = ascii_chars[char]
        char_line = pattern[line_idx]? || "       "
        line += char_line
      else
        line += "       "
      end
    end
    
    # Pad to fit the box width (59 chars total)
    while line.size < 58
      line += " "
    end
    line += "║"
    puts line
  end
  
  puts "║                                                           ║"
  puts "║               Kothari API Framework                       ║"
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
  system "mkdir -p #{app_name}/config/initializers"
  system "mkdir -p #{app_name}/src"
  system "mkdir -p #{app_name}/db/migrations"

  # shard.yml
  # Prefer a local path to the framework when developing it alongside an app.
  # Check if we're in the framework directory itself, or if kothari_api exists as sibling
  dependency_block =
    if File.exists?("src/cli/kothari.cr") || File.exists?("shard.yml") && File.read("shard.yml").includes?("name: kothari_api")
      # We're in the framework directory, use parent path
      "  kothari_api:\n    path: ..\n"
    elsif Dir.exists?("kothari_api")
      # App will live in a sibling directory, so the shard path is ../kothari_api
      "  kothari_api:\n    path: ../kothari_api\n"
    else
      # Use GitHub version
      "  kothari_api:\n    github: backlinkedclub/kothari_api\n    version: ~> 0.1.0\n"
    end

  File.write "#{app_name}/shard.yml", <<-YAML
name: #{app_name}
version: 0.1.0

dependencies:
#{dependency_block}

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

  # CORS configuration (like Rails config/initializers/cors.rb)
  File.write "#{app_name}/config/initializers/cors.cr", <<-CORS
# CORS (Cross-Origin Resource Sharing) Configuration
#
# This file controls which applications/domains are allowed to access your API.
# CORS is a security feature that prevents unauthorized websites from making
# requests to your API from a browser.

KothariAPI::CORS.configure(
  # allowed_origins: List of domains that can access your API
  #   - Use specific domains: ["https://example.com", "https://app.example.com"]
  #   - Use "*" to allow all origins (NOT recommended for production)
  #   - Leave empty [] to disable CORS
  allowed_origins: [
    "http://localhost:3000",
    "http://localhost:5173",  # Vite default port
    "http://localhost:8080",  # Vue CLI default port
    # Add your production domains here:
    # "https://yourdomain.com",
    # "https://app.yourdomain.com"
  ],

  # allowed_methods: HTTP methods that are allowed
  #   - GET: Fetch data
  #   - POST: Create new resources
  #   - PUT: Update entire resource
  #   - PATCH: Partially update resource
  #   - DELETE: Delete resource
  #   - OPTIONS: Preflight request (required for CORS)
  allowed_methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],

  # allowed_headers: Request headers that clients can send
  #   - Content-Type: Required for JSON requests
  #   - Authorization: Required for JWT/auth tokens
  #   - Accept: What content types the client accepts
  #   - Add custom headers your API needs
  allowed_headers: [
    "Content-Type",
    "Authorization",
    "Accept",
    "X-Requested-With"
  ],

  # exposed_headers: Response headers that clients can read
  #   - These headers are made available to JavaScript in the browser
  #   - Leave empty [] if you don't need to expose custom headers
  exposed_headers: [],

  # max_age: How long (in seconds) browsers can cache preflight responses
  #   - 3600 = 1 hour (default)
  #   - Higher values reduce preflight requests but increase cache time
  #   - Set to 0 to disable caching
  max_age: 3600,

  # allow_credentials: Whether to allow cookies/auth headers
  #   - true: Allows cookies and authentication headers (use with specific origins)
  #   - false: More secure, doesn't allow credentials (default)
  #   - If true, you CANNOT use "*" for allowed_origins
  allow_credentials: false
)
CORS

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
require "../config/initializers/cors"
require "http/server"
require "mime"

# Auto-connect database
KothariAPI::DB.connect("db/development.sqlite3")

server = HTTP::Server.new do |context|
  begin
    # Handle CORS preflight requests (OPTIONS)
    if KothariAPI::CORS.handle_preflight(context)
      next
    end

    method = context.request.method.to_s.upcase
    path = context.request.path
    origin = context.request.headers["Origin"]?
    
    # Serve static files from public directory
    if path.starts_with?("/uploads/")
      file_path = path.lchop("/")
      full_path = File.join("public", file_path)
      
      if File.exists?(full_path) && File.file?(full_path)
        context.response.content_type = MIME.from_filename(full_path) || "application/octet-stream"
        context.response.headers["Content-Length"] = File.size(full_path).to_s
        File.open(full_path) do |file|
          IO.copy(file, context.response)
        end
        next
      else
        context.response.status = HTTP::Status::NOT_FOUND
        context.response.print "File not found"
        next
      end
    else
      # Use match_with_params to extract path parameters (e.g., :id from /posts/:id)
      match_result = KothariAPI::Router::Router.match_with_params(method, path)

      if match_result
        route, path_params = match_result
        controller_class = KothariAPI::ControllerRegistry.lookup(route.controller)

        if controller_class
          controller = controller_class.new(context)
          # Merge path parameters into controller's params
          controller.merge_path_params(path_params)
          controller.send(route.action)
        else
          context.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
          context.response.print({error: "Controller not found"}.to_json)
        end
      else
        context.response.status = HTTP::Status::NOT_FOUND
        context.response.content_type = "application/json"
        context.response.print({error: "Not Found"}.to_json)
      end
    end

    # Apply CORS headers to all responses
    KothariAPI::CORS.apply_headers(context, origin)
  rescue ex
    STDERR.puts "Unhandled error: \#{ex.message}"
    ex.backtrace?.try &.each { |ln| STDERR.puts ln }
    context.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
    context.response.content_type = "application/json"
    context.response.print({error: "Internal Server Error"}.to_json)
    
    # Apply CORS headers even on errors
    origin = context.request.headers["Origin"]?
    KothariAPI::CORS.apply_headers(context, origin)
  end
end

port_str = ENV["KOTHARI_PORT"]?
requested_port = port_str ? port_str.to_i : 3000
port = requested_port
max_attempts = 10
attempt = 0

loop do
  begin
    server.bind_tcp "0.0.0.0", port
    if port != requested_port
      puts "\e[33m⚠ Port \#{requested_port} is in use. Using port \#{port} instead.\e[0m"
    end
    puts "Running on http://localhost:\#{port}"
    break
  rescue ex : Socket::BindError
    attempt += 1
    if attempt >= max_attempts
      STDERR.puts "\e[31m✗ Error: Could not find an available port after \#{max_attempts} attempts\e[0m"
      exit 1
    end
    port += 1
  end
end

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
puts "\e[36m║           KOTHARI API CONSOLE - DATA EXPLORER             ║\e[0m"
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
    puts "\e[32m║                    AVAILABLE COMMANDS                     ║\e[0m"
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
                  begin
                    # Read value as DB::Any to handle different types
                    val = rs.read(::DB::Any)
                    case val
                    when Nil
                      "NULL"
                    when Int32, Int64
                      val.to_s
                    when String
                      val
                    when Float32, Float64
                      val.to_s
                    when Bool
                      val.to_s
                    else
                      val.to_s
                    end
                  rescue
                    "NULL"
                  end
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
      # Handle: Session.where("live = 1") or Session.where('live = 1')
      name = cmd.split(".").first.strip.downcase
      # Improved regex to handle both single and double quotes with optional whitespace
      # This pattern handles: .where("..."), .where('...'), .where( "..."), etc.
      # Try double quotes first, then single quotes
      condition_match = cmd.match(/\\.where\\s*\\(\\s*"([^"]+)"\\s*\\)/) || cmd.match(/\\.where\\s*\\(\\s*'([^']+)'\\s*\\)/)
      
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
        puts "\e[31m✗ Invalid .where() syntax. Use: Model.where('condition')\e[0m"
      end
    elsif cmd.includes?(".find(")
      # Handle: Session.find(1) or session.find(1)
      name = cmd.split(".").first.strip.downcase
      # Improved regex to handle optional whitespace and extract digits even with quotes
      # This handles: .find(1), .find( 1 ), .find("1"), .find('1'), etc.
      id_match = cmd.match(/\\.find\\s*\\(\\s*["']?(\\d+)["']?\\s*\\)/)
      
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
  puts "  \e[36mkothari server\e[0m \e[90m[-p|--port PORT]\e[0m"
  puts "\n\e[32mHappy coding! 🚀\e[0m\n"
  exit 0
end

# ===============================================
# kothari server [-p|--port PORT]
# ===============================================
if ARGV[0]? == "server"
  unless File.exists?("src/server.cr")
    puts "\e[31m✗ Error: src/server.cr not found\e[0m"
    puts "\e[33mMake sure you're in a Kothari app root directory (where src/server.cr exists).\e[0m"
    exit 1
  end

  # Ensure shards are installed so that `require "kothari_api"` works when compiling.
  unless Dir.exists?("lib")
    puts "\e[36m⚡ Installing shards (this may take a moment)...\e[0m"
    unless system("shards install")
      puts "\e[31m✗ Error: shards install failed. Please check the output above.\e[0m"
      exit 1
    end
  end

  port = 3000
  
  # Parse port flag
  i = 1
  while i < ARGV.size
    arg = ARGV[i]?
    if arg == "-p" || arg == "--port"
      if i + 1 < ARGV.size
        port_str = ARGV[i + 1]?
        if port_str
          port = port_str.to_i? || 3000
          i += 2
        else
          i += 1
        end
      else
        puts "\e[31m✗ Error: Port number required after -p/--port flag\e[0m"
        exit 1
      end
    else
      i += 1
    end
  end
  
  # Pass port as environment variable - merge with existing environment
  env = ENV.to_h
  env["KOTHARI_PORT"] = port.to_s
  
  # Use Process.run to ensure environment variable is passed correctly
  # Explicitly set chdir to current directory to ensure Crystal finds shards
  Process.run("crystal", ["run", "src/server.cr"], 
    chdir: Dir.current,
    env: env,
    output: Process::Redirect::Inherit,
    error: Process::Redirect::Inherit
  )
  exit 0
end

# ===============================================
# kothari build [output_name] [--release]
# ===============================================
if ARGV[0]? == "build"
  show_intro("build")
  unless File.exists?("src/server.cr")
    puts "\e[31m✗ Error: src/server.cr not found\e[0m"
    puts "\e[33mMake sure you're in a Kothari app root directory (where src/server.cr exists).\e[0m"
    exit 1
  end

  # Ensure shards are installed so that `require "kothari_api"` works when compiling.
  unless Dir.exists?("lib")
    puts "\e[36m⚡ Installing shards (this may take a moment)...\e[0m"
    unless system("shards install")
      puts "\e[31m✗ Error: shards install failed. Please check the output above.\e[0m"
      exit 1
    end
  end

  app_name = File.basename(Dir.current)
  output   = ARGV[1]? || app_name

  cmd = "crystal build src/server.cr -o #{output}"
  if ARGV.includes?("--release")
    cmd += " --release"
  end

  puts "\e[36m⚡ Building app (#{output})...\e[0m"
  if system(cmd)
    puts "\e[32m✓ Build complete: ./#{output}\e[0m"
    exit 0
  else
    puts "\e[31m✗ Build failed. Please review the compiler errors above.\e[0m"
    exit 1
  end
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
    sql_type = case type.downcase
               when "string", "text" then "TEXT"
               when "int", "integer" then "INTEGER"
               when "bigint", "int64" then "INTEGER"
               when "float", "double" then "REAL"
               when "bool", "boolean" then "INTEGER"
               when "json", "json::any" then "TEXT"
               when "time", "datetime", "timestamp" then "TEXT"
               when "uuid" then "TEXT"
               else
                 "TEXT"
               end
    "#{key} #{sql_type}"
  end.join(", ")

  # Derive the actual table name.
  # Convention: if the migration name starts with "create_",
  # use the remainder as the table name (e.g. "create_posts" -> "posts").
  # Otherwise, use the name as-is.
  table_name =
    if name.starts_with?("create_")
      name.sub(/^create_/, "")
    else
      name
    end

  # Add timestamps to all tables
  timestamp_columns = ",\n  created_at TEXT DEFAULT CURRENT_TIMESTAMP,\n  updated_at TEXT DEFAULT CURRENT_TIMESTAMP"
  
  File.write filename, <<-SQL
CREATE TABLE IF NOT EXISTS #{table_name} (
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
  
  # Ensure db directory exists
  system "mkdir -p db"
  
  puts "\e[36m⚡ Connecting to database...\e[0m"
  begin
    KothariAPI::DB.connect("db/development.sqlite3")
  rescue ex
    puts "\e[31m✗ Database connection failed: #{ex.message}\e[0m"
    puts "\e[33m  Make sure you're in a KothariAPI app directory\e[0m"
    exit 1
  end
  
  puts "\e[36m⚡ Running migrations...\e[0m"
  begin
    KothariAPI::Migrator.migrate
    puts "\e[32m✓ Migrations complete.\e[0m\n"
  rescue ex
    puts "\e[31m✗ Migration failed: #{ex.message}\e[0m"
    exit 1
  end
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
                   when "json", "json::any" then "JSON::Any"
                   when "time", "datetime", "timestamp" then "Time"
                   when "uuid" then "String"
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
                   when "json", "json::any" then "JSON::Any"
                   when "time", "datetime", "timestamp" then "Time"
                   when "uuid" then "String"
                   else
                     type.camelcase
                   end
    "@#{key} : #{crystal_type}"
  end.join(", ")

  system "mkdir -p app/models"

  # Add id and timestamp fields to scaffold model
  id_ivar = "@id : Int64?"
  id_property = "property id : Int64?"
  timestamp_ivars = "\n  @created_at : String?\n  @updated_at : String?"
  timestamp_args = ", @created_at : String? = nil, @updated_at : String? = nil"
  id_arg = ", @id : Int64? = nil"
  
  # Generate property declarations for all fields
  model_properties = fields.map do |f|
    key, type = f.split(":")
    crystal_type = case type.downcase
                   when "string", "text"   then "String"
                   when "int", "integer"    then "Int32"
                   when "bigint", "int64"   then "Int64"
                   when "float", "double"   then "Float64"
                   when "bool", "boolean"   then "Bool"
                   when "json", "json::any" then "JSON::Any"
                   when "time", "datetime", "timestamp" then "Time"
                   when "uuid" then "String"
                   else
                     "String"
                   end
    "property #{key} : #{crystal_type}"
  end.join("\n  ")
  timestamp_properties = "\n  property created_at : String?\n  property updated_at : String?"
  
  File.write "app/models/#{name}.cr", <<-MODEL
class #{class_name} < KothariAPI::Model
  table "#{name}s"

  #{id_ivar}
  #{ivars}#{timestamp_ivars}

  #{id_property}
  #{model_properties}#{timestamp_properties}

  #{fields.empty? ? "" : "def initialize(#{ctor_args}#{timestamp_args}#{id_arg})\n  end"}

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

  @id : Int64?
  @email : String
  @password_digest : String
  @created_at : String?
  @updated_at : String?

  property id : Int64?
  property email : String
  property password_digest : String
  property created_at : String?
  property updated_at : String?

  def initialize(@email : String, @password_digest : String, @created_at : String? = nil, @updated_at : String? = nil, @id : Int64? = nil)
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

    # Include user_id in JWT for easier lookup
    token = KothariAPI::Auth::JWTAuth.issue_simple({
      "email" => email.not_nil!,
      "user_id" => user.id.not_nil!
    })
    context.response.status = HTTP::Status::CREATED
    json({token: token, email: email.not_nil!, user_id: user.id})
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

    # Include user_id in JWT for easier lookup
    token = KothariAPI::Auth::JWTAuth.issue_simple({
      "email" => email.not_nil!,
      "user_id" => user.id.not_nil!
    })
    context.response.status = HTTP::Status::OK
    json({token: token, email: email.not_nil!, user_id: user.id})
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
                   when "json", "json::any" then "JSON::Any"
                   when "time", "datetime", "timestamp" then "Time"
                   when "uuid" then "String"
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
                   when "json", "json::any" then "JSON::Any"
                   when "time", "datetime", "timestamp" then "Time"
                   when "uuid" then "String"
                   else
                     "String"  # Default to String for unknown types
                   end
    "@#{key} : #{crystal_type}"
  end.join(", ")

  system "mkdir -p app/models"

  # Add id and timestamp fields to model
  id_ivar = "@id : Int64?"
  id_property = "property id : Int64?"
  timestamp_ivars = "\n  @created_at : String?\n  @updated_at : String?"
  timestamp_args = ", @created_at : String? = nil, @updated_at : String? = nil"
  id_arg = ", @id : Int64? = nil"
  
  # Generate property declarations for all fields
  model_properties = fields.map do |f|
    key, type = f.split(":")
    crystal_type = case type.downcase
                   when "string", "text"   then "String"
                   when "int", "integer"    then "Int32"
                   when "bigint", "int64"   then "Int64"
                   when "float", "double"   then "Float64"
                   when "bool", "boolean"   then "Bool"
                   when "json", "json::any" then "JSON::Any"
                   when "time", "datetime", "timestamp" then "Time"
                   when "uuid" then "String"
                   else
                     "String"
                   end
    "property #{key} : #{crystal_type}"
  end.join("\n  ")
  timestamp_properties = "\n  property created_at : String?\n  property updated_at : String?"
  
  File.write "app/models/#{model_file_name}.cr", <<-MODEL
class #{class_name} < KothariAPI::Model
  table "#{plural}"

  #{id_ivar}
  #{model_ivars}#{timestamp_ivars}

  #{id_property}
  #{model_properties}#{timestamp_properties}

  #{fields.empty? ? "" : "def initialize(#{model_ctor_args}#{timestamp_args}#{id_arg})\n  end"}

  KothariAPI::ModelRegistry.register("#{singular}", #{class_name})
end
MODEL

  # 2) Migration
  timestamp = Time.utc.to_unix_ms.to_s
  mig_filename = "db/migrations/#{timestamp}_create_#{plural}.sql"

  columns_sql = fields.map do |f|
    key, type = f.split(":")
    sql_type = case type.downcase
               when "string", "text" then "TEXT"
               when "int", "integer" then "INTEGER"
               when "bigint", "int64" then "INTEGER"
               when "float", "double" then "REAL"
               when "bool", "boolean" then "INTEGER"
               when "json", "json::any" then "TEXT"
               when "time", "datetime", "timestamp" then "TEXT"
               when "uuid" then "TEXT"
               else
                 "TEXT"
               end
    "#{key} #{sql_type}"
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
    json_get(#{class_name}.all)
  end

  # GET /#{plural}/:id
  # Shows a single #{class_name} record by ID.
  def show
    id = params["id"]?.try &.to_i?
    if id && (record = #{class_name}.find(id))
      json_get(record)
    else
      not_found("#{class_name} not found")
    end
  end

  # POST /#{plural}
  # Creates a new #{class_name} from JSON body using strong params.
  def create
    attrs = #{singular}_params
    begin
      record = #{class_name}.create(
        #{fields.map do |f|
            key, type = f.split(":")
            crystal_type = case type.downcase
                           when "int", "integer" then "attrs[\"#{key}\"].as_i? || attrs[\"#{key}\"].to_s.to_i"
                           when "bigint", "int64" then "attrs[\"#{key}\"].as_i64? || attrs[\"#{key}\"].to_s.to_i64"
                           when "float", "double" then "attrs[\"#{key}\"].as_f? || attrs[\"#{key}\"].to_s.to_f"
                           when "bool", "boolean" then "attrs[\"#{key}\"].as_bool? || attrs[\"#{key}\"].to_s == \"true\""
                           when "json", "json::any" then "attrs[\"#{key}\"].as_h? || JSON.parse(attrs[\"#{key}\"].to_s)"
                           when "time", "datetime", "timestamp" then "Time.parse(attrs[\"#{key}\"].to_s, \"%Y-%m-%d %H:%M:%S\", Time::Location::UTC)"
                           when "uuid" then "attrs[\"#{key}\"].to_s"
                           else
                             "attrs[\"#{key}\"].to_s"
                           end
            "#{key}: #{crystal_type}"
          end.join(",\n        ")}
      )
      json_post(record)
    rescue ex
      unprocessable_entity("Failed to create #{class_name}", {"details" => JSON::Any.new(ex.message || "Unknown error")})
    end
  end

  # PATCH/PUT /#{plural}/:id
  # Updates a #{class_name} record by ID.
  def update
    id = params["id"]?.try &.to_i?
    unless id
      bad_request("ID parameter required")
      return
    end
    
    record = #{class_name}.find(id)
    unless record
      not_found("#{class_name} not found")
      return
    end
    
    attrs = #{singular}_params
    begin
      # Update record using raw SQL (models need to implement update method)
      updated = #{class_name}.update(id, attrs)
      if updated
        json_update(#{class_name}.find(id))
      else
        unprocessable_entity("Failed to update #{class_name}")
      end
    rescue ex
      unprocessable_entity("Failed to update #{class_name}", {"details" => JSON::Any.new(ex.message || "Unknown error")})
    end
  end

  # DELETE /#{plural}/:id
  # Deletes a #{class_name} record by ID.
  def destroy
    id = params["id"]?.try &.to_i?
    unless id
      bad_request("ID parameter required")
      return
    end
    
    record = #{class_name}.find(id)
    unless record
      not_found("#{class_name} not found")
      return
    end
    
    begin
      if #{class_name}.delete(id)
        json_delete({message: "#{class_name} deleted successfully"})
      else
        internal_server_error("Failed to delete #{class_name}")
      end
    rescue ex
      internal_server_error("Failed to delete #{class_name}", {"details" => JSON::Any.new(ex.message || "Unknown error")})
    end
  end
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
  puts "  \e[36mkothari server\e[0m \e[90m[-p|--port PORT]\e[0m"
  puts "\n\e[32mReady to go! 🚀\e[0m\n"
  exit 0
end

# ===============================================
# kothari console
# ===============================================
if ARGV[0]? == "console"
  show_intro("console")
  # Delegate to the app's console entrypoint which we generated as
  # `console.cr` in the app root.
  unless File.exists?("console.cr")
    puts "\e[31m✗ Error: console.cr not found\e[0m"
    puts "\e[33mMake sure you're in a KothariAPI app directory.\e[0m\n"
    exit 1
  end
  
  # Check if shards are installed
  unless File.exists?("lib") || Dir.exists?("lib")
    puts "\e[33m⚠ Warning: lib directory not found. Running 'shards install'...\e[0m"
    system "shards install"
    unless $?.success?
      puts "\e[31m✗ Error: Failed to install shards\e[0m"
      puts "\e[33mPlease run 'shards install' manually and try again.\e[0m\n"
      exit 1
    end
  end
  
  # Run console with proper shard context
  # Use crystal run which automatically loads shards from shard.yml
  system "crystal run console.cr"
  exit $?.success? ? 0 : 1
end

# ===============================================
# kothari routes
# ===============================================
if ARGV[0]? == "routes"
  show_intro("routes")
  
  unless File.exists?("config/routes.cr")
    puts "\e[31m✗ Error: config/routes.cr not found\e[0m"
    puts "\e[33mMake sure you're in a KothariAPI app directory.\e[0m\n"
    exit 1
  end

  # Parse routes file directly to extract route information
  routes_content = File.read("config/routes.cr")
  routes = [] of Tuple(String, String, String)
  
  # Extract routes using regex
  route_pattern = /r\.(get|post|put|patch|delete)\s+"([^"]+)",\s+to:\s+"([^"]+)"/
  routes_content.scan(route_pattern) do |match|
    method = match[1].upcase
    path = match[2]
    controller_action = match[3]
    routes << {method, path, controller_action}
  end
  
  if routes.empty?
    puts "\e[33m⚠ No routes found in config/routes.cr\e[0m"
  else
    puts "\e[32m╔═══════════════════════════════════════════════════════════╗\e[0m"
    puts "\e[32m║                      ROUTES TABLE                         ║\e[0m"
    puts "\e[32m╚═══════════════════════════════════════════════════════════╝\e[0m"
    puts ""
    puts "\e[33mMethod    Path                    Controller#Action\e[0m"
    puts "-" * 60
    
    routes.each do |method, path, controller_action|
      method_color = case method
                    when "GET"    then "\e[32m"
                    when "POST"   then "\e[33m"
                    when "PUT"    then "\e[34m"
                    when "PATCH"  then "\e[35m"
                    when "DELETE" then "\e[31m"
                    else               "\e[0m"
                    end
      
      method_str = "#{method_color}#{method.ljust(6)}\e[0m"
      path_str = path.ljust(22)
      
      puts "#{method_str}  #{path_str}  #{controller_action}"
    end
    
    puts ""
    puts "\e[33mTotal: \e[36m#{routes.size}\e[33m route(s)\e[0m"
  end
  
  puts ""
  exit 0
end

# ===============================================
# kothari document
# ===============================================
if ARGV[0]? == "document"
  show_intro("document")
  
  unless File.exists?("config/routes.cr")
    puts "\e[31m✗ Error: config/routes.cr not found\e[0m"
    puts "\e[33mMake sure you're in a KothariAPI app directory.\e[0m\n"
    exit 1
  end

  unless File.exists?("README.md")
    # Auto-create README.md if missing
    File.write("README.md", "# #{File.basename(Dir.current)}\n\nA KothariAPI application.\n")
    puts "\e[33m⚠ README.md not found. Created a basic README.md.\e[0m"
  end

  # Parse routes file
  routes_content = File.read("config/routes.cr")
  routes = [] of Tuple(String, String, String, String) # method, path, controller, action
  
  route_pattern = /r\.(get|post|put|patch|delete)\s+"([^"]+)",\s+to:\s+"([^"]+)"/
  routes_content.scan(route_pattern) do |match|
    method = match[1].upcase
    path = match[2]
    controller_action = match[3]
    parts = controller_action.split("#")
    controller = parts[0]
    action = parts[1]? || "index"
    routes << {method, path, controller, action}
  end

  if routes.empty?
    puts "\e[33m⚠ No routes found in config/routes.cr\e[0m"
    exit 0
  end

  # Build documentation
  doc_sections = [] of String
  
  # Group routes by controller
  routes_by_controller = {} of String => Array(Tuple(String, String, String, String))
  routes.each do |route|
    method, path, controller, action = route
    routes_by_controller[controller] ||= [] of Tuple(String, String, String, String)
    routes_by_controller[controller] << route
  end

  # Generate documentation for each controller
  routes_by_controller.each do |controller_name, controller_routes|
    # Find controller file
    controller_path = nil
    possible_paths = [
      "app/controllers/#{controller_name}_controller.cr",
      "app/controllers/#{controller_name}.cr",
    ]
    possible_paths.each do |path|
      if File.exists?(path)
        controller_path = path
        break
      end
    end
    
    # Get model name from controller
    model_name = if controller_name.ends_with?("s")
      controller_name[0..-2]
    else
      controller_name
    end
    
    # Find model fields
    model_fields = {} of String => String
    if model_name
      model_path = "app/models/#{model_name.downcase}.cr"
      if File.exists?(model_path)
        model_content = File.read(model_path)
        
        # Extract property declarations
        property_pattern = /property\s+(\w+)\s*:\s*([\w:?]+)/
        model_content.scan(property_pattern) do |match|
          field_name = match[1]
          field_type = match[2]
          model_fields[field_name] = field_type
        end
        
        # Also check for instance variables in initialize
        ivar_pattern = /@(\w+)\s*:\s*([\w:?]+)/
        model_content.scan(ivar_pattern) do |match|
          field_name = match[1]
          next if field_name == "errors" # Skip errors field
          field_type = match[2]
          model_fields[field_name] = field_type unless model_fields.has_key?(field_name)
        end
      end
    end
    
    doc_sections << "### #{controller_name.capitalize} Endpoints\n"
    
    controller_routes.each do |route|
      method, path, _, action = route
      
      # Extract parameters from controller
      params = [] of String
      if controller_path && File.exists?(controller_path)
        controller_content = File.read(controller_path)
        
        # Look for permit_body calls in the action
        action_pattern = Regex.new("def\\s+#{action}.*?end", Regex::Options::MULTILINE)
        if action_match = controller_content.match(action_pattern)
          action_code = action_match[0]
          
          # Extract permit_body parameters
          permit_body_pattern = /permit_body\s*\(\s*([^)]+)\s*\)/
          if permit_match = action_code.match(permit_body_pattern)
            params_str = permit_match[1]
            # Extract quoted strings
            params_str.scan(/"([^"]+)"/) do |param_match|
              params << param_match[1]
            end
          end
          
          # Extract permit_params parameters
          permit_params_pattern = /permit_params\s*\(\s*([^)]+)\s*\)/
          if permit_match = action_code.match(permit_params_pattern)
            params_str = permit_match[1]
            params_str.scan(/"([^"]+)"/) do |param_match|
              params << param_match[1]
            end
          end
          
          # Extract parameters from json_body patterns (for auth endpoints)
          # Look for patterns like: data["email"], data["password"], etc.
          json_body_pattern = /(?:data|json_body)\["(\w+)"\]/
          action_code.scan(json_body_pattern) do |param_match|
            param_name = param_match[1]
            params << param_name unless params.includes?(param_name)
          end
          
          # Check for path parameters (e.g., :id)
          if action_code.includes?("params[\"id\"]")
            params << "id" unless params.includes?("id")
          end
        end
      end
      
      # Add path parameters
      path.scan(/:(\w+)/) do |param_match|
        param_name = param_match[1]
        params << param_name unless params.includes?(param_name)
      end
      
      # Build endpoint documentation
      doc_sections << "#### `#{method} #{path}`\n"
      doc_sections << "\n**Action:** `#{controller_name}##{action}`\n\n"
      
      # Parameters
      if params.any?
        doc_sections << "**Parameters:**\n\n"
        params.each do |param|
          is_path_param = path.includes?(":#{param}")
          param_type = if model_fields.has_key?(param)
            model_fields[param]
          elsif param == "id"
            "Int64"
          else
            "String"
          end
          
          if is_path_param
            doc_sections << "- `#{param}` (path, #{param_type}) - Required path parameter\n"
          elsif method == "GET"
            doc_sections << "- `#{param}` (query, #{param_type}) - Optional query parameter\n"
          else
            doc_sections << "- `#{param}` (body, #{param_type}) - Required in request body\n"
          end
        end
        doc_sections << "\n"
      end
      
      # Request example
      if method == "POST" || method == "PUT" || method == "PATCH"
        request_body_parts = [] of String
        params.each do |param|
          next if path.includes?(":#{param}") # Skip path params
          case model_fields[param]?
          when "String", "String?"
            request_body_parts << "\"#{param}\": \"example_#{param}\""
          when "Int32", "Int32?", "Int64", "Int64?"
            request_body_parts << "\"#{param}\": 1"
          when "Bool", "Bool?"
            request_body_parts << "\"#{param}\": true"
          when "Float64", "Float64?"
            request_body_parts << "\"#{param}\": 1.0"
          else
            request_body_parts << "\"#{param}\": \"value\""
          end
        end
        
        if request_body_parts.any?
          doc_sections << "**Request Example:**\n\n"
          doc_sections << "```json\n"
          doc_sections << "{\n  " + request_body_parts.join(",\n  ") + "\n}\n"
          doc_sections << "```\n\n"
        end
      end
      
      # Response example
      if model_fields.any?
        doc_sections << "**Response Example:**\n\n"
        doc_sections << "```json\n"
        
        response_body_parts = [] of String
        model_fields.each do |field, type|
          case type
          when "String", "String?"
            response_body_parts << "\"#{field}\": \"example_#{field}\""
          when "Int32", "Int32?", "Int64", "Int64?"
            response_body_parts << "\"#{field}\": 1"
          when "Bool", "Bool?"
            response_body_parts << "\"#{field}\": true"
          when "Float64", "Float64?"
            response_body_parts << "\"#{field}\": 1.0"
          else
            response_body_parts << "\"#{field}\": null"
          end
        end
        
        doc_sections << "{\n  " + response_body_parts.join(",\n  ") + "\n}\n"
        doc_sections << "```\n\n"
      end
      
      doc_sections << "---\n\n"
    end
  end

  # Generate full documentation
  full_doc = <<-DOC
## API Documentation

> **Note:** This documentation is auto-generated. Run `kothari document` to update it.

#{doc_sections.join}

DOC

  # Print to terminal
  puts "\e[32m╔═══════════════════════════════════════════════════════════╗\e[0m"
  puts "\e[32m║                  API DOCUMENTATION                       ║\e[0m"
  puts "\e[32m╚═══════════════════════════════════════════════════════════╝\e[0m"
  puts ""
  
  routes_by_controller.each do |controller_name, controller_routes|
    puts "\e[33m#{controller_name.capitalize} Endpoints:\e[0m"
    controller_routes.each do |route|
      method, path, _, action = route
      method_color = case method
                    when "GET"    then "\e[32m"
                    when "POST"   then "\e[33m"
                    when "PUT"    then "\e[34m"
                    when "PATCH"  then "\e[35m"
                    when "DELETE" then "\e[31m"
                    else               "\e[0m"
                    end
      
      puts "  #{method_color}#{method.ljust(6)}\e[0m #{path.ljust(30)} #{controller_name}##{action}"
    end
    puts ""
  end

  # Update README.md
  readme_content = File.read("README.md")
  
  # Find or create API Documentation section
  doc_start_marker = "## API Documentation"
  
  if readme_content.includes?(doc_start_marker)
    # Replace existing documentation section
    lines = readme_content.lines
    start_idx = nil
    end_idx = nil
    
    lines.each_with_index do |line, idx|
      if line.strip == doc_start_marker && start_idx.nil?
        start_idx = idx
      elsif start_idx && line.starts_with?("## ") && line.strip != doc_start_marker && idx > start_idx
        end_idx = idx
        break
      end
    end
    
    if start_idx
      # Remove old documentation including the header line
      if end_idx
        lines = lines[0...start_idx] + lines[end_idx..-1]
      else
        lines = lines[0...start_idx]
      end
      
      # Insert new documentation (which includes the header)
      new_lines = full_doc.lines
      lines = lines[0..start_idx] + new_lines + lines[start_idx..-1]
      readme_content = lines.join("\n")
    else
      # Fallback: append at end
      readme_content += "\n\n#{full_doc}"
    end
  else
    # Add documentation section before License or Support, or at the end
    if readme_content.includes?("## License")
      readme_content = readme_content.sub("## License", "#{full_doc}## License")
    elsif readme_content.includes?("## Support")
      readme_content = readme_content.sub("## Support", "#{full_doc}## Support")
    else
      readme_content += "\n\n#{full_doc}"
    end
  end
  
  File.write("README.md", readme_content)
  
  puts "\e[32m✓\e[0m Documentation updated in \e[36mREADME.md\e[0m"
  puts "\e[33mTotal: \e[36m#{routes.size}\e[33m endpoint(s) documented\e[0m"
  puts ""
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
    puts "  \e[36mkothari server\e[0m \e[90m[-p|--port PORT]\e[0m"
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
  # Show "KOTHARI" for no args, "HELP" for help command
  command_name = ARGV.empty? ? "kothari" : "help"
  show_intro(command_name)

  puts "\e[36m╔═══════════════════════════════════════════════════════════╗\e[0m"
  puts "\e[36m║                  AVAILABLE COMMANDS                      ║\e[0m"
  puts "\e[36m╚═══════════════════════════════════════════════════════════╝\e[0m"
  puts ""
  puts "\e[33m📦 App Management:\e[0m"
  puts "  \e[36mkothari new\e[0m \e[90m<app_name>\e[0m"
  puts "     Create a new KothariAPI application"
  puts ""
  puts "\e[33m🚀 Server:\e[0m"
  puts "  \e[36mkothari server\e[0m \e[90m[-p|--port PORT]\e[0m"
  puts "     Start the development server (default: port 3000)"
  puts ""
  puts "  \e[36mkothari build\e[0m \e[90m[output] [--release]\e[0m"
  puts "     Compile application into a binary"
  puts ""
  puts "\e[33m⚡ Generators:\e[0m"
  puts "  \e[36mkothari g controller\e[0m \e[90m<name>\e[0m"
  puts "     Generate a new controller"
  puts ""
  puts "  \e[36mkothari g model\e[0m \e[90m<name> [field:type ...]\e[0m"
  puts "     Generate a new model with optional fields"
  puts ""
  puts "  \e[36mkothari g migration\e[0m \e[90m<name> [field:type ...]\e[0m"
  puts "     Generate a new database migration"
  puts ""
  puts "  \e[36mkothari g scaffold\e[0m \e[90m<name> [field:type ...]\e[0m"
  puts "     Generate model, controller, migration, and routes"
  puts ""
  puts "  \e[36mkothari g auth\e[0m \e[90m[name]\e[0m"
  puts "     Generate authentication (User model, AuthController, routes)"
  puts ""
  puts "\e[33m🗄️  Database:\e[0m"
  puts "  \e[36mkothari db:migrate\e[0m"
  puts "     Run pending database migrations"
  puts ""
  puts "  \e[36mkothari db:reset\e[0m"
  puts "     Drop, create, and migrate the database"
  puts ""
  puts "\e[33m🛠️  Utilities:\e[0m"
  puts "  \e[36mkothari routes\e[0m"
  puts "     List all registered routes"
  puts ""
  puts "  \e[36mkothari document\e[0m"
  puts "     Generate and update API documentation in README.md"
  puts ""
  puts "  \e[36mkothari console\e[0m"
  puts "     Open an interactive console"
  puts ""
  puts "  \e[36mkothari benchmark\e[0m"
  puts "     Run performance benchmarks"
  puts ""
  puts "  \e[36mkothari help\e[0m"
  puts "     Show this help message"
  puts ""
  puts "\e[32m╔═══════════════════════════════════════════════════════════╗\e[0m"
  puts "\e[32m║  For more information: https://github.com/kothari-api   ║\e[0m"
  puts "\e[32m║  Version: \e[36m1.0.0\e[32m                                          ║\e[0m"
  puts "\e[32m╚═══════════════════════════════════════════════════════════╝\e[0m"
  puts ""
  exit 0
end
