require "http/server"
require "json"

module KothariAPI
  class Controller
    getter context : HTTP::Server::Context

    @params : Hash(String, String)
    @json_body : Hash(String, JSON::Any) | Nil

    def initialize(@context)
      # Pre-initialize params so the instance variable is never nil.
      @params = {} of String => String
      @json_body = nil
    end

    # JSON response helper – use this in actions to respond with JSON.
    def json(data)
      context.response.content_type = "application/json"
      context.response.print data.to_json
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
    def send(action : String)
      # Handle standard REST actions
      case action
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
    def params : Hash(String, String)
      qp = context.request.query_params
      @params ||= (qp ? qp.to_h : {} of String => String)
      @params
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
  end
end

