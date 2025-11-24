class CommentsController < KothariAPI::Controller
  # GET /comments
  # Lists all Comment records as JSON.
  def index
    json(Comment.all)
  end

  # GET /comments/:id
  # NOTE: Path params are not yet wired; you can fetch by query param
  # e.g. /s?id=1 for now.
  def show
    id = params["id"]?.try &.to_i?
    if id && (record = Comment.find(id))
      json(record)
    else
      context.response.status = HTTP::Status::NOT_FOUND
      json({ error: "Not Found" })
    end
  end

  # POST /s
  # Creates a new Comment from JSON body using strong params.
  def create
    attrs = comment_params
    record = Comment.create(
      content: attrs["content"].to_s,
      article_id: attrs["article_id"].as_i? || attrs["article_id"].to_s.to_i
    )

    context.response.status = HTTP::Status::CREATED
    json(record)
  end

  # PATCH/PUT /comments/:id
  # TODO: Implement update by id (e.g. with raw SQL).
  def update
    json({ message: "update not implemented yet" })
  end

  # DELETE /comments/:id
  # TODO: Implement destroy by id.
  def destroy
    json({ message: "destroy not implemented yet" })
  end

  private def comment_params
    # Strong params example – only allow the whitelisted keys from
    # the JSON request body.
    permit_body(
      "content", "article_id"
    )
  end
end

KothariAPI::ControllerRegistry.register("comments", CommentsController)