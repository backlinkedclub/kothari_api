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
      action_sym = action.to_sym
      
      if only
        return only.includes?(action_sym)
      end
      
      if except
        return !except.includes?(action_sym)
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
      error_data = {"error" => message}
      error_data["errors"] = errors if errors
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
  end
end

