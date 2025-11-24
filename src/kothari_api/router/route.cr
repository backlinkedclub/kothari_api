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
  end
end
