# Authentication Guide for KothariAPI

## Using JWT Authentication

### Getting the Current User

The framework provides `KothariAPI::Auth::JWTAuth.decode(token)` for decoding JWT tokens.

**Example `current_user` method:**

```crystal
class PostsController < KothariAPI::Controller
  private def current_user
    auth_header = context.request.headers["Authorization"]?
    return nil unless auth_header
    
    # Extract token from "Bearer <token>"
    token = auth_header.lchop("Bearer ").strip
    return nil if token.empty?
    
    begin
      payload = KothariAPI::Auth::JWTAuth.decode(token)
      email = payload["email"]?.try &.as_s
      return nil unless email
      
      # Find user by email
      User.find_by_email(email)
    rescue KothariAPI::Auth::JWTError
      nil  # Invalid or expired token
    end
  end
  
  def create
    user = current_user
    unless user
      unauthorized("Authentication required")
      return
    end
    
    # Create post with user_id
    attrs = post_params
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      user_id: user.id
    )
    
    context.response.status = HTTP::Status::CREATED
    json(post)
  end
end
```

### Route Parameters

Currently, the router uses exact path matching. For routes like `/posts/:id`, you need to parse the path manually:

```crystal
def show
  # Extract ID from path like "/posts/123"
  path_parts = context.request.path.split("/").reject(&.empty?)
  post_id = path_parts.last?.try &.to_i?
  
  unless post_id
    not_found("Post ID required")
    return
  end
  
  post = Post.find(post_id)
  unless post
    not_found("Post not found")
    return
  end
  
  json(post)
end
```

**Alternative:** Use query parameters for now:
```crystal
# Route: GET /posts?id=123
def show
  id = params["id"]?.try &.to_i?
  # ...
end
```

## Complete Example

```crystal
class PostsController < KothariAPI::Controller
  before_action :authenticate_user, only: [:create, :update, :destroy]
  
  def index
    json(Post.all)
  end
  
  def show
    id = extract_id_from_path
    post = Post.find(id) if id
    if post
      json(post)
    else
      not_found("Post not found")
    end
  end
  
  def create
    attrs = post_params
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      user_id: @current_user.not_nil!.id
    )
    context.response.status = HTTP::Status::CREATED
    json(post)
  end
  
  private def authenticate_user
    @current_user = current_user
    unless @current_user
      unauthorized("Authentication required")
    end
  end
  
  private def current_user
    auth_header = context.request.headers["Authorization"]?
    return nil unless auth_header
    
    token = auth_header.lchop("Bearer ").strip
    return nil if token.empty?
    
    begin
      payload = KothariAPI::Auth::JWTAuth.decode(token)
      email = payload["email"]?.try &.as_s
      return nil unless email
      User.find_by_email(email)
    rescue KothariAPI::Auth::JWTError
      nil
    end
  end
  
  private def extract_id_from_path
    path_parts = context.request.path.split("/").reject(&.empty?)
    path_parts.last?.try &.to_i?
  end
  
  private def post_params
    permit_body("title", "content")
  end
end
```

