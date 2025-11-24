require "jwt"

module KothariAPI
  module Auth
    class JWTError < Exception; end

    # Thin wrapper around the `jwt` shard to keep KothariAPI's
    # public API small and consistent.
    module JWTAuth
      def self.secret : String
        ENV["KOTHARI_JWT_SECRET"]? || "change-me-jwt-secret"
      end

      # Issue a JWT with the given payload and expiration (seconds from now).
      # Payload keys are strings; exp is added automatically.
      def self.issue(payload : Hash(String, JSON::Any), expires_in : Int32 = 3600) : String
        exp = Time.utc.to_unix + expires_in
        full = payload.merge({"exp" => JSON::Any.new(exp)})
        JWT.encode(full, secret, JWT::Algorithm::HS256)
      end

      # Convenience overload for simple String => String/Int payloads.
      def self.issue_simple(payload : Hash(String, String | Int32), expires_in : Int32 = 3600) : String
        json_payload = {} of String => JSON::Any
        payload.each do |k, v|
          json_payload[k] = JSON::Any.new(v)
        end
        issue(json_payload, expires_in)
      end

      # Verify and decode a token, returning the payload hash.
      def self.decode(token : String) : Hash(String, JSON::Any)
        begin
          payload, _header = JWT.decode(token, secret, JWT::Algorithm::HS256)
          payload.as_h
        rescue e
          raise JWTError.new("Invalid token: #{e.message}")
        end
      end
    end
  end
end





