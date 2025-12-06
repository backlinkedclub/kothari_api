require "http/server"
require "json"

module KothariAPI
  class Controller
    getter context : HTTP::Server::Context

    @params : Hash(String, String)
    @json_body : Hash(String, JSON::Any) | Nil
    @current_user : Nil = nil

    def initialize(@context)
      # Pre-initialize params so the instance variable is never nil.
      @params = {} of String => String
      @json_body = nil
    end

    # -------- Callbacks (Rails-style before_action/after_action) --------
    
    # Class-level storage for callbacks (per class, not shared)
    class_getter before_action_callbacks : Array({Symbol, Array(Symbol)?, Array(Symbol)?}) = [] of {Symbol, Array(Symbol)?, Array(Symbol)?}
    class_getter after_action_callbacks : Array({Symbol, Array(Symbol)?, Array(Symbol)?}) = [] of {Symbol, Array(Symbol)?, Array(Symbol)?}

    # Register a before_action callback
    # Usage:
    #   before_action :authenticate_user!
    #   before_action :set_post, only: [:show, :update, :destroy]
    #   before_action :check_permission, except: [:index, :show]
    def self.before_action(method_name : Symbol, only : Array(Symbol)? = nil, except : Array(Symbol)? = nil)
      before_action_callbacks << {method_name, only, except}
    end

    # Register an after_action callback
    # Usage:
    #   after_action :log_action
    #   after_action :set_cache_headers, only: [:index, :show]
    def self.after_action(method_name : Symbol, only : Array(Symbol)? = nil, except : Array(Symbol)? = nil)
      after_action_callbacks << {method_name, only, except}
    end

    # Check if a callback should run for a given action
    private def should_run_callback?(action : String, only : Array(Symbol)?, except : Array(Symbol)?) : Bool
      # Convert action string to symbol for comparison
      action_str = action
      
      if only
        return only.any? { |sym| sym.to_s == action_str }
      end
      
      if except
        return !except.any? { |sym| sym.to_s == action_str }
      end
      
      true
    end

    # Run before_action callbacks
    private def run_before_actions(action : String)
      self.class.before_action_callbacks.each do |callback|
        method_name, only, except = callback
        if should_run_callback?(action, only, except)
          # Call the method - this will be resolved at runtime
          begin
            result = case method_name
            when :authenticate_user!
              authenticate_user!
            else
              # Try to call the method by name
              # Note: This requires the method to be defined in the controller subclass
              call_callback_method(method_name)
            end
            
            # If callback returns false or response is closed, stop processing
            return false if result == false || context.response.closed?
          rescue ex
            # Method doesn't exist or error occurred
            STDERR.puts "Callback error: #{ex.message}" if ENV["DEBUG"]?
            next
          end
        end
      end
      true
    end

    # Run after_action callbacks
    private def run_after_actions(action : String)
      self.class.after_action_callbacks.each do |callback|
        method_name, only, except = callback
        if should_run_callback?(action, only, except)
          begin
            # Call the method
            case method_name
            else
              call_callback_method(method_name)
            end
          rescue ex
            # Method doesn't exist or error occurred
            STDERR.puts "Callback error: #{ex.message}" if ENV["DEBUG"]?
            next
          end
        end
      end
    end

    # Helper to call callback methods dynamically
    # This uses method_missing-style lookup - methods must be defined in subclasses
    private def call_callback_method(method_name : Symbol)
      # Try common callback method names
      case method_name.to_s
      when "authenticate_user!"
        authenticate_user!
      when "set_post", "set_user", "set_resource"
        # These are common patterns - subclasses should define them
        raise "Callback method #{method_name} not implemented. Define it as a private method in your controller."
      else
        raise "Callback method #{method_name} not found. Make sure it's defined as a private method in your controller."
      end
    end

    # JSON response helper – use this in actions to respond with JSON.
    def json(data)
      context.response.content_type = "application/json"
      context.response.print data.to_json
    end
    
    # JSON helpers for different HTTP methods
    
    # GET response - returns 200 OK with JSON data
    def json_get(data)
      context.response.status = HTTP::Status::OK
      json(data)
    end
    
    # POST response - returns 201 Created with JSON data
    def json_post(data)
      context.response.status = HTTP::Status::CREATED
      json(data)
    end
    
    # UPDATE/PATCH response - returns 200 OK with JSON data
    def json_update(data)
      context.response.status = HTTP::Status::OK
      json(data)
    end
    
    # PATCH response - alias for json_update
    def json_patch(data)
      json_update(data)
    end
    
    # DELETE response - returns 200 OK with JSON data (or 204 No Content if data is nil)
    def json_delete(data = nil)
      if data.nil?
        context.response.status = HTTP::Status::NO_CONTENT
        context.response.print ""
      else
        context.response.status = HTTP::Status::OK
        json(data)
      end
    end

    # Standardized error responses
    def error_response(status : HTTP::Status, message : String, details : Hash(String, JSON::Any)? = nil)
      context.response.status = status
      context.response.content_type = "application/json"
      error_data = {"error" => message}
      error_data["details"] = details if details
      context.response.print error_data.to_json
    end

    def bad_request(message : String = "Bad Request", details : Hash(String, JSON::Any)? = nil)
      error_response(HTTP::Status::BAD_REQUEST, message, details)
    end

    def unauthorized(message : String = "Unauthorized", details : Hash(String, JSON::Any)? = nil)
      error_response(HTTP::Status::UNAUTHORIZED, message, details)
    end

    def forbidden(message : String = "Forbidden", details : Hash(String, JSON::Any)? = nil)
      error_response(HTTP::Status::FORBIDDEN, message, details)
    end

    def not_found(message : String = "Not Found", details : Hash(String, JSON::Any)? = nil)
      error_response(HTTP::Status::NOT_FOUND, message, details)
    end

    def unprocessable_entity(message : String = "Unprocessable Entity", errors : Hash(String, Array(String))? = nil)
      context.response.status = HTTP::Status::UNPROCESSABLE_ENTITY
      context.response.content_type = "application/json"
      error_data = {} of String => JSON::Any
      error_data["error"] = JSON::Any.new(message)
      error_data["errors"] = JSON::Any.new(errors.to_json) if errors
      context.response.print error_data.to_json
    end

    def internal_server_error(message : String = "Internal Server Error", details : Hash(String, JSON::Any)? = nil)
      error_response(HTTP::Status::INTERNAL_SERVER_ERROR, message, details)
    end

    # Explicit dispatcher for common REST-style actions.
    # Also handles custom actions like "signup", "login", etc.
    # Runs before_action and after_action callbacks automatically.
    def send(action : String)
      # Run before_action callbacks
      unless run_before_actions(action)
        return  # Callback stopped the request (e.g., unauthorized)
      end

      # Handle standard REST actions
      result = case action
      when "index"   then index
      when "show"    then show
      when "create"  then create
      when "update"  then update
      when "destroy" then destroy
      when "signup"  then signup
      when "login"   then login
      else
        raise "Unknown action #{action} for #{self.class}"
      end

      # Run after_action callbacks
      run_after_actions(action)
      
      result
    end

    # Default REST actions – controllers are expected to override
    # these as needed.

    def index
      context.response.content_type = "application/json"
      context.response.print({ error: "index not implemented" }.to_json)
    end

    def show
      context.response.status = HTTP::Status::NOT_IMPLEMENTED
      json({ error: "show not implemented for #{self.class}" })
    end

    def create
      context.response.status = HTTP::Status::NOT_IMPLEMENTED
      json({ error: "create not implemented for #{self.class}" })
    end

    def update
      context.response.status = HTTP::Status::NOT_IMPLEMENTED
      json({ error: "update not implemented for #{self.class}" })
    end

    def destroy
      context.response.status = HTTP::Status::NOT_IMPLEMENTED
      json({ error: "destroy not implemented for #{self.class}" })
    end

    # Custom action methods - subclasses can override these
    def signup
      context.response.status = HTTP::Status::NOT_IMPLEMENTED
      json({ error: "signup not implemented for #{self.class}" })
    end

    def login
      context.response.status = HTTP::Status::NOT_IMPLEMENTED
      json({ error: "login not implemented for #{self.class}" })
    end

    # -------- Params & strong params --------

    # Query string parameters as a simple Hash(String, String).
    # Path parameters (from routes like /posts/:id) are automatically merged in.
    def params : Hash(String, String)
      qp = context.request.query_params
      @params ||= (qp ? qp.to_h : {} of String => String)
      @params
    end
    
    # Merge path parameters (from route patterns like /posts/:id) into params.
    # This is called by the server when matching routes with path parameters.
    def merge_path_params(path_params : Hash(String, String))
      path_params.each do |key, value|
        @params[key] = value
      end
    end

    # Strong params for query string – only the listed keys are kept.
    def permit_params(*keys : String) : Hash(String, String)
      allowed = {} of String => String
      keys.each do |key|
        if value = params[key]?
          allowed[key] = value
        end
      end
      allowed
    end

    # Require a query param; raises if missing.
    def require_param(key : String) : String
      value = params[key]?
      raise "Missing required param #{key}" unless value
      value
    end

    # Lazy-parse JSON request body into a hash; used by strong params.
    def json_body : Hash(String, JSON::Any)
      return @json_body.not_nil! if @json_body

      body_io = context.request.body
      body = if body_io
               body_io.gets_to_end
             else
               ""
             end

      parsed =
        if body.empty?
          {} of String => JSON::Any
        else
          begin
            JSON.parse(body).as_h
          rescue
            {} of String => JSON::Any
          end
        end

      @json_body = parsed
      parsed
    end

    # Handle multipart form data (for file uploads)
    # Returns an array of form data parts
    def form_data : Array(HTTP::FormData::Part)?
      content_type = context.request.headers["Content-Type"]?
      return nil unless content_type && content_type.includes?("multipart/form-data")
      
      boundary = content_type.split("boundary=").last?.try &.strip
      return nil unless boundary
      
      body_io = context.request.body
      return nil unless body_io
      
      parts = [] of HTTP::FormData::Part
      
      begin
        HTTP::FormData.parse(body_io, boundary) do |part|
          parts << part
        end
        parts.empty? ? nil : parts
      rescue ex
        STDERR.puts "Form data parse error: #{ex.message}" if ENV["DEBUG"]?
        nil
      end
    end
    
    # Get uploaded file from form data
    def uploaded_file(field_name : String) : HTTP::FormData::Part?
      form = form_data
      return nil unless form
      
      form.each do |part|
        return part if part.name == field_name && part.filename
      end
      nil
    end
    
    # Strong params for JSON body – only the listed keys are kept.
    def permit_body(*keys : String) : Hash(String, JSON::Any)
      data = json_body
      allowed = {} of String => JSON::Any
      keys.each do |key|
        if value = data[key]?
          allowed[key] = value
        end
      end
      allowed
    end

    # -------- Authentication Helpers --------

    # Get the current authenticated user (cached per request)
    # Override this method in your controllers to customize user lookup
    # This default implementation looks for a User model and finds by user_id or email from JWT
    def current_user
      return @current_user if @current_user
      
      auth_header = context.request.headers["Authorization"]?
      return nil unless auth_header
      
      # Extract token from "Bearer <token>"
      token = auth_header.lchop("Bearer ").strip
      return nil if token.empty?
      
      begin
        payload = KothariAPI::Auth::JWTAuth.decode(token)
        user_id = payload["user_id"]?.try &.as_i?
        email = payload["email"]?.try &.as_s
        
        # Default implementation - subclasses should override for custom logic
        # This will work if you have a User model with find and find_by methods
        user = nil
        
        # Try to find by user_id first (if JWT contains user_id)
        if user_id
          user = find_user_by_id(user_id)
        end
        
        # Fallback to email lookup (most common with kothari g auth)
        if !user && email
          user = find_user_by_email(email)
        end
        
        @current_user = user
        user
      rescue KothariAPI::Auth::JWTError
        nil  # Invalid or expired token
      end
    end

    # Helper to find user by ID
    # Override this in your controller if you have a User model:
    #   private def find_user_by_id(user_id)
    #     User.find(user_id)
    #   end
    private def find_user_by_id(user_id)
      # Default: return nil - subclasses should override
      nil
    end

    # Helper to find user by email
    # Override this in your controller if you have a User model:
    #   private def find_user_by_email(email)
    #     User.find_by("email", email)
    #   end
    private def find_user_by_email(email : String)
      # Default: return nil - subclasses should override
      nil
    end

    # Authenticate user - use in before_action
    # Stops the request and returns 401 Unauthorized if no user is found
    def authenticate_user!
      user = current_user
      unless user
        unauthorized("Authentication required")
        return false
      end
      true
    end

    # Check if user is authenticated
    def user_signed_in?
      !current_user.nil?
    end

    # Get current user ID (convenience method)
    def current_user_id
      user = current_user
      user.try &.id
    end

    # -------- Webhook Helper --------
    
    # Webhook helper macro - generates webhook methods (for use in webhook controllers)
    # Usage:
    #   webhook "incoming_call" do
    #     data = json_body
    #     # Process webhook data
    #     json({status: "received"})
    #   end
    #
    # After adding webhook() calls, run: kothari webhook:routes
    # to automatically add routes to config/routes.cr
    macro webhook(method_name, &block)
      {% 
        method_name_str = method_name.id.stringify
        controller_class_name = @type.name
        # Extract base name from controller class (e.g., TwilioWebhookController -> twilio_webhook)
        controller_name_underscore = controller_class_name.underscore
        base_name = controller_name_underscore.gsub(/_webhook_controller$/, "")
        route_path = "/webhooks/#{base_name}/#{method_name_str}"
      %}
      
      # Webhook endpoint: {{route_path}}
      # Auto-route: POST {{route_path}} -> {{controller_name_underscore}}#{{method_name_str}}
      def {{method_name.id}}
        {{block.body}}
      end
    end
    
    # Webhook helper method - dynamically creates webhook methods and routes
    # Usage from any controller:
    #   def create
    #     webhook_url = Webhook(controller_name: "twilio", action_name: "new_method")
    #     json({webhook_url: webhook_url})
    #   end
    #
    # This automatically:
    #   1. Creates a separate file for the webhook method (app/webhooks/<controller>/<action>.cr)
    #   2. Adds require statement to the webhook controller
    #   3. Adds the route to config/routes.cr
    #   4. Returns the webhook URL
    #
    # Note: Server restart required after calling to pick up new routes
    def self.webhook(controller_name : String, action_name : String) : String
      # Find or create the webhook controller file
      webhook_controller_path = "app/controllers/#{controller_name}_webhook_controller.cr"
      
      unless File.exists?(webhook_controller_path)
        raise "Webhook controller not found: #{webhook_controller_path}. Run 'kothari webhook #{controller_name}' first."
      end
      
      # Create webhook method file in app/webhooks/<controller>/<action>.cr
      webhook_dir = "app/webhooks/#{controller_name}"
      system "mkdir -p #{webhook_dir}"
      webhook_file_path = "#{webhook_dir}/#{action_name}.cr"
      
      # Check if webhook file already exists
      if File.exists?(webhook_file_path)
        # File exists, just return the URL
        return "/webhooks/#{controller_name}/#{action_name}"
      end
      
      # Generate the webhook method file
      # This file will be required in the webhook controller
      webhook_class_name = "#{controller_name.camelcase}WebhookController"
      # Use action_name in module name to make it unique per action
      module_name = "#{controller_name.camelcase}#{action_name.camelcase}Webhook"
      webhook_file_content = <<-CRYSTAL
# Webhook method: #{action_name}
# Auto-generated by Webhook() helper
# File: app/webhooks/#{controller_name}/#{action_name}.cr
#
# This file can be edited directly for meta-programming and updates.
# The method is automatically included in #{webhook_class_name} via module inclusion

module KothariAPI
  module Webhooks
    module #{module_name}
      # Webhook endpoint: /webhooks/#{controller_name}/#{action_name}
      def #{action_name}
        data = json_body
        # TODO: Implement webhook logic here
        json({status: "received", action: "#{action_name}"})
      end
    end
  end
end

# Include the method in the webhook controller
#{webhook_class_name}.include(KothariAPI::Webhooks::#{module_name})
CRYSTAL
      
      File.write(webhook_file_path, webhook_file_content)
      
      # Read the controller file
      controller_content = File.read(webhook_controller_path)
      
      # Check if require already exists
      require_path = "./webhooks/#{controller_name}/#{action_name}"
      if controller_content.includes?("require \"#{require_path}\"") || controller_content.includes?("require '#{require_path}'")
        # Already required, skip
      else
        # Add require statement to controller
        # Find a good place to insert it (after other requires, before class definition)
        lines = controller_content.lines
        require_index = nil
        
        # Find the last require statement
        lines.each_with_index do |line, i|
          if line.strip.starts_with?("require")
            require_index = i
          elsif line.strip.starts_with?("class") && require_index
            # Found class definition, insert before it
            require_index = i
            break
          end
        end
        
        if require_index.nil?
          # No requires found, add after first line (or at line 1 if file is empty)
          require_index = lines.empty? ? 0 : 1
        end
        
        require_line = "require \"#{require_path}\""
        lines.insert(require_index, require_line)
        File.write(webhook_controller_path, lines.join("\n") + "\n")
      end
      
      # Add route to routes.cr
      routes_path = "config/routes.cr"
      unless File.exists?(routes_path)
        raise "Routes file not found: #{routes_path}"
      end
      
      routes_content = File.read(routes_path)
      route_line = "  r.post \"/webhooks/#{controller_name}/#{action_name}\", to: \"#{controller_name}_webhook##{action_name}\""
      
      # Check if route already exists
      if routes_content.includes?(route_line)
        return "/webhooks/#{controller_name}/#{action_name}"
      end
      
      # Find the last 'end' in routes
      routes_lines = routes_content.lines
      end_index = routes_lines.rindex { |l| l.strip == "end" }
      
      if end_index
        routes_lines.insert(end_index, route_line)
        File.write(routes_path, routes_lines.join("\n") + "\n")
      else
        File.open(routes_path, "a") do |f|
          f.puts route_line
        end
      end
      
      # Return the webhook URL
      "/webhooks/#{controller_name}/#{action_name}"
    end
    
    # Instance method wrapper for Webhook helper
    # Usage in controller methods:
    #   def create
    #     webhook_url = Webhook(controller_name: "twilio", action_name: "new_method")
    #     json({webhook_url: webhook_url})
    #   end
    def webhook(controller_name : String, action_name : String) : String
      KothariAPI::Controller.webhook(controller_name, action_name)
    end
    
    # Webhook update helper - rewrites/updates an existing webhook file
    # Usage from any controller:
    #   def update_sequences
    #     # Rewrite the webhook file with new logic
    #     Webhook.update(controller_name: "twilio", action_name: "messaging_profile_1") do
    #       # This block contains the new webhook logic
    #       # It will replace the entire method in the file
    #     end
    #   end
    #
    # This rewrites the webhook file with new logic, useful for:
    # - Updating message sequences
    # - Changing business logic
    # - Meta-programming based on user actions
    def self.webhook_update(controller_name : String, action_name : String, &block)
      # Find the webhook file
      webhook_file_path = "app/webhooks/#{controller_name}/#{action_name}.cr"
      
      unless File.exists?(webhook_file_path)
        raise "Webhook file not found: #{webhook_file_path}. Create it first using Webhook() helper."
      end
      
      # Read the current file
      current_content = File.read(webhook_file_path)
      
      # Extract the block body as a string (we'll need to get it from the caller)
      # Since we can't easily extract block body at runtime, we'll use a different approach
      # The caller will provide the new method body as a string
      
      webhook_class_name = "#{controller_name.camelcase}WebhookController"
      module_name = "#{controller_name.camelcase}#{action_name.camelcase}Webhook"
      
      # Generate new file content with updated method
      # Note: The block body will be provided by the caller as a string
      new_file_content = <<-CRYSTAL
# Webhook method: #{action_name}
# Auto-generated by Webhook() helper
# File: app/webhooks/#{controller_name}/#{action_name}.cr
#
# This file can be edited directly for meta-programming and updates.
# Last updated: #{Time.utc.to_s}

module KothariAPI
  module Webhooks
    module #{module_name}
      # Webhook endpoint: /webhooks/#{controller_name}/#{action_name}
      def #{action_name}
        {{block.body}}
      end
    end
  end
end

# Include the method in the webhook controller
#{webhook_class_name}.include(KothariAPI::Webhooks::#{module_name})
CRYSTAL
      
      # Write the updated file
      File.write(webhook_file_path, new_file_content)
      
      "/webhooks/#{controller_name}/#{action_name}"
    end
    
    # Webhook update helper with method body as string
    # Usage:
    #   Webhook.update(controller_name: "twilio", action_name: "profile_1", method_body: "data = json_body\njson({status: 'updated'})")
    def self.webhook_update(controller_name : String, action_name : String, method_body : String) : String
      # Find the webhook file
      webhook_file_path = "app/webhooks/#{controller_name}/#{action_name}.cr"
      
      unless File.exists?(webhook_file_path)
        raise "Webhook file not found: #{webhook_file_path}. Create it first using Webhook() helper."
      end
      
      webhook_class_name = "#{controller_name.camelcase}WebhookController"
      module_name = "#{controller_name.camelcase}#{action_name.camelcase}Webhook"
      
      # Generate new file content with updated method
      new_file_content = <<-CRYSTAL
# Webhook method: #{action_name}
# Auto-generated by Webhook() helper
# File: app/webhooks/#{controller_name}/#{action_name}.cr
#
# This file can be edited directly for meta-programming and updates.
# Last updated: #{Time.utc.to_s}

module KothariAPI
  module Webhooks
    module #{module_name}
      # Webhook endpoint: /webhooks/#{controller_name}/#{action_name}
      def #{action_name}
        puts "this is #{action_name}"
#{method_body.split("\n").map { |line| "        #{line}" }.join("\n")}
      end
    end
  end
end

# Include the method in the webhook controller
#{webhook_class_name}.include(KothariAPI::Webhooks::#{module_name})
CRYSTAL
      
      # Write the updated file
      File.write(webhook_file_path, new_file_content)
      
      "/webhooks/#{controller_name}/#{action_name}"
    end
    
    # Instance method wrapper for Webhook.update
    # Usage:
    #   def update_sequences
    #     method_body = generate_webhook_logic_from_sequences()
    #     Webhook.update(controller_name: "twilio", action_name: "profile_1", method_body: method_body)
    #   end
    def webhook_update(controller_name : String, action_name : String, method_body : String) : String
      KothariAPI::Controller.webhook_update(controller_name, action_name, method_body)
    end
  end
end

