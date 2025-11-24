require "./route"

module KothariAPI
  module Router
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

      def self.match(method : String, path : String)
        @@routes.find { |r| r.method == method && r.path == path }
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
