class HomeController < KothariAPI::Controller
  # GET /
  # This is the default landing action for a new KothariAPI app.
  def index
    json({ message: "Welcome to KothariAPI" })
  end
end

KothariAPI::ControllerRegistry.register("home", HomeController)