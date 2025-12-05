require "http/server"

module KothariAPI
  module CORS
    # Default CORS configuration
    @@allowed_origins = [] of String
    @@allowed_methods = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    @@allowed_headers = ["Content-Type", "Authorization", "Accept"]
    @@exposed_headers = [] of String
    @@max_age = 3600
    @@allow_credentials = false
    @@enabled = false

    # Configure CORS settings
    def self.configure(
      allowed_origins : Array(String) = [] of String,
      allowed_methods : Array(String) = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
      allowed_headers : Array(String) = ["Content-Type", "Authorization", "Accept"],
      exposed_headers : Array(String) = [] of String,
      max_age : Int32 = 3600,
      allow_credentials : Bool = false
    )
      @@allowed_origins = allowed_origins
      @@allowed_methods = allowed_methods
      @@allowed_headers = allowed_headers
      @@exposed_headers = exposed_headers
      @@max_age = max_age
      @@allow_credentials = allow_credentials
      @@enabled = true
    end

    # Check if CORS is enabled
    def self.enabled?
      @@enabled
    end

    # Get allowed origins
    def self.allowed_origins
      @@allowed_origins
    end

    # Get allowed methods
    def self.allowed_methods
      @@allowed_methods
    end

    # Get allowed headers
    def self.allowed_headers
      @@allowed_headers
    end

    # Get exposed headers
    def self.exposed_headers
      @@exposed_headers
    end

    # Get max age
    def self.max_age
      @@max_age
    end

    # Get allow credentials
    def self.allow_credentials
      @@allow_credentials
    end

    # Check if origin is allowed
    def self.origin_allowed?(origin : String) : Bool
      return true if @@allowed_origins.empty? # Allow all if no origins specified
      return true if @@allowed_origins.includes?("*") # Allow all if wildcard
      @@allowed_origins.includes?(origin)
    end

    # Apply CORS headers to response
    def self.apply_headers(context : HTTP::Server::Context, origin : String?)
      return unless enabled?
      return unless origin

      # Check if origin is allowed
      unless origin_allowed?(origin)
        return
      end

      # Set CORS headers
      context.response.headers["Access-Control-Allow-Origin"] = origin
      context.response.headers["Access-Control-Allow-Methods"] = @@allowed_methods.join(", ")
      context.response.headers["Access-Control-Allow-Headers"] = @@allowed_headers.join(", ")
      context.response.headers["Access-Control-Max-Age"] = @@max_age.to_s

      if @@exposed_headers.any?
        context.response.headers["Access-Control-Expose-Headers"] = @@exposed_headers.join(", ")
      end

      if @@allow_credentials
        context.response.headers["Access-Control-Allow-Credentials"] = "true"
      end
    end

    # Handle preflight OPTIONS request
    def self.handle_preflight(context : HTTP::Server::Context) : Bool
      return false unless enabled?
      return false unless context.request.method == "OPTIONS"

      origin = context.request.headers["Origin"]?
      return false unless origin

      unless origin_allowed?(origin)
        context.response.status = HTTP::Status::FORBIDDEN
        return true
      end

      # Get requested method and headers from preflight request
      requested_method = context.request.headers["Access-Control-Request-Method"]?
      requested_headers = context.request.headers["Access-Control-Request-Headers"]?

      # Check if requested method is allowed
      if requested_method && !@@allowed_methods.includes?(requested_method.upcase)
        context.response.status = HTTP::Status::FORBIDDEN
        return true
      end

      # Set preflight response headers
      context.response.status = HTTP::Status::NO_CONTENT
      context.response.headers["Access-Control-Allow-Origin"] = origin
      context.response.headers["Access-Control-Allow-Methods"] = @@allowed_methods.join(", ")
      context.response.headers["Access-Control-Allow-Headers"] = @@allowed_headers.join(", ")
      context.response.headers["Access-Control-Max-Age"] = @@max_age.to_s

      if @@allow_credentials
        context.response.headers["Access-Control-Allow-Credentials"] = "true"
      end

      true
    end
  end
end

