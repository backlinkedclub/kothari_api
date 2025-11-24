class BlogController < KothariAPI::Controller
  # GET /blog
  # TODO: implement this action. For example, you might render a list
  # of records or some static JSON.
  def index
    json({ message: "Blog#index" })
  end
end

KothariAPI::ControllerRegistry.register("blog", BlogController)