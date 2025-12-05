module KothariAPI
  module Router
    class Route
      getter method : String
      getter path : String
      getter controller : String
      getter action : String

      def initialize(@method : String, @path : String, to : String)
        parts = to.split("#")
        @controller = parts[0]
        @action = parts[1]? || "index"
      end
    end

    class Router
      @@routes = [] of Route

      def self.get(path : String, to : String)
        @@routes << Route.new("GET", path, to)
      end

      def self.post(path : String, to : String)
        @@routes << Route.new("POST", path, to)
      end

      def self.put(path : String, to : String)
        @@routes << Route.new("PUT", path, to)
      end

      def self.patch(path : String, to : String)
        @@routes << Route.new("PATCH", path, to)
      end

      def self.delete(path : String, to : String)
        @@routes << Route.new("DELETE", path, to)
      end

      def self.routes
        @@routes
      end

      # Route matching with support for simple `:param` style path segments.
      #
      # Examples:
      #   pattern: "/articles"       path: "/articles"        -> {}
      #   pattern: "/articles/:id"   path: "/articles/1"      -> {"id" => "1"}
      #   pattern: "/users/:uid/posts/:id" path: "/users/5/posts/9" -> {"uid" => "5", "id" => "9"}
      #
      # These helpers are used by the server to dispatch requests and to
      # populate `params` in controllers with path parameters.
      def self.match_with_params(method : String, path : String) : {Route, Hash(String, String)}?
        @@routes.each do |route|
          next unless route.method == method

          if params = match_path(route.path, path)
            return {route, params}
          end
        end

        nil
      end

      # Backwards-compatible matcher: return only the Route (no params).
      def self.match(method : String, path : String) : Route?
        if result = match_with_params(method, path)
          result[0]
        else
          nil
        end
      end

      # Internal path pattern matcher. Returns a Hash of path params if the
      # pattern matches the actual path, or nil otherwise.
      def self.match_path(pattern : String, actual : String) : Hash(String, String)?
        pattern_segments = pattern.split("/").reject(&.empty?)
        actual_segments = actual.split("/").reject(&.empty?)

        # Root path special case: "/" vs "/"
        if pattern_segments.empty? && actual_segments.empty?
          return {} of String => String
        end

        return nil unless pattern_segments.size == actual_segments.size

        params = {} of String => String

        pattern_segments.zip(actual_segments) do |p, a|
          if p.starts_with?(":")
            key = p.lchop(":")
            params[key] = a
          elsif p != a
            return nil
          end
        end

        params
      end

      # DSL: KothariAPI::Router::Router.draw do |r| ... end
      #
      # Use Crystal's implicit block + yield so the compiler knows
      # this method yields exactly one argument (the router itself).
      def self.draw
        yield self
      end
    end
  end
end
