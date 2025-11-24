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
    STDERR.puts "Unhandled error: #{ex.message}"
    ex.backtrace?.try &.each { |ln| STDERR.puts ln }
    context.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
    context.response.content_type = "application/json"
    context.response.print({error: "Internal Server Error"}.to_json)
  end
end

puts "Running on http://localhost:3000"
server.bind_tcp "0.0.0.0", 3000
server.listen