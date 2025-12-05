# Kothari API Framework

A lightweight, Rails-inspired web framework for Crystal. Build fast, type-safe APIs with minimal boilerplate.

![Kothari API Framework](https://img.shields.io/badge/Kothari-API%20Framework-blue)
![Crystal](https://img.shields.io/badge/Crystal-1.0+-brightgreen)

## Features

- 🚀 **Fast CLI** - Generate apps, models, controllers, and more
- 🎨 **Beautiful ASCII Banners** - Dynamic command banners for every command
- 🗄️ **Database Migrations** - SQLite-based migrations with automatic timestamps
- 🔐 **Built-in Authentication** - JWT-based auth with password hashing
- 📦 **Scaffold Generator** - Full CRUD scaffolding with one command
- 🛣️ **Route Management** - Simple DSL for defining routes
- 📊 **Interactive Console** - Explore your data with an interactive REPL
- 🎯 **Type-Safe** - Full Crystal type safety throughout

## Installation

### Prerequisites

- Crystal 1.0 or higher
- SQLite3 (for database)

### Install Kothari CLI

```bash
# Clone the repository
git clone https://github.com/backlinkedclub/kothari_api.git
cd kothari_api

# Install dependencies
shards install

# Build the CLI
crystal build src/cli/kothari.cr -o kothari

# Install globally (optional)
sudo mv kothari /usr/local/bin/kothari
```

## Quick Start

```bash
# Create a new app
kothari new myapp
cd myapp

# Install dependencies
shards install

# Generate a scaffold
kothari g scaffold post title:string content:text

# Run migrations
kothari db:migrate

# Start the server
kothari server
```

Visit `http://localhost:3000/posts` to see your API in action!

## CLI Commands

### App Management

#### `kothari new <app_name>`

Creates a new KothariAPI application with the standard directory structure.

```bash
kothari new blog_api
cd blog_api
shards install
```

**Generated Structure:**
```
myapp/
├── app/
│   ├── controllers/
│   └── models/
├── config/
│   └── routes.cr
├── db/
│   └── migrations/
├── src/
│   └── server.cr
└── shard.yml
```

#### `kothari server [-p|--port PORT]`

Starts the development server. Default port is 3000.

```bash
# Default port (3000)
kothari server

# Custom port
kothari server -p 3001
kothari server --port 5000
```

#### `kothari build [output] [--release]`

Compiles your application into a binary.

```bash
# Build with default name
kothari build

# Build with custom name
kothari build myapp

# Build optimized release
kothari build myapp --release
```

### Generators

#### `kothari g model <name> [field:type ...]`

Generates a new model with optional fields.

```bash
# Simple model
kothari g model user

# Model with fields
kothari g model article title:string content:text views:integer
```

**Supported Data Types:**
- `string`, `text` → `String`
- `int`, `integer` → `Int32`
- `bigint`, `int64` → `Int64`
- `float`, `double` → `Float64`
- `bool`, `boolean` → `Bool`
- `json`, `json::any` → `JSON::Any`
- `time`, `datetime`, `timestamp` → `Time`
- `uuid` → `String`
- `reference`, `ref` → `Int32` (creates foreign key with index, e.g., `user_id:reference`)

#### `kothari g migration <name> [field:type ...]`

Generates a database migration.

```bash
kothari g migration create_users email:string password_digest:string
kothari db:migrate
```

#### `kothari g controller <name>`

Generates a new controller with an `index` action and route.

```bash
kothari g controller blog
# Creates BlogController with GET /blog route
```

#### `kothari g scaffold <name> [field:type ...]`

Generates a complete CRUD scaffold: model, migration, controller, and routes.

```bash
# Generate scaffold
kothari g scaffold post title:string content:text published:bool

# Run migrations
kothari db:migrate

# Start server
kothari server
```

**Generated Routes:**
- `GET /posts` - List all posts
- `POST /posts` - Create a new post
- `GET /posts/:id` - Show a post
- `PATCH /posts/:id` - Update a post
- `DELETE /posts/:id` - Delete a post

#### `kothari g auth [name]`

Generates authentication system with User model, AuthController, and routes.

```bash
kothari g auth
kothari db:migrate
```

**Generated Routes:**
- `POST /signup` - Register a new user
- `POST /login` - Authenticate and get JWT token

**Example Usage:**
```bash
# Signup
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secure123"}'

# Login
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secure123"}'
```

### Database Commands

#### `kothari db:migrate`

Runs all pending database migrations.

```bash
kothari db:migrate
```

#### `kothari db:reset`

Drops the database, recreates it, and runs all migrations.

```bash
kothari db:reset
```

### Utility Commands

#### `kothari routes`

Lists all registered routes in a formatted table.

```bash
kothari routes
```

**Output:**
```
╔═══════════════════════════════════════════════════════════╗
║                      ROUTES TABLE                         ║
╚═══════════════════════════════════════════════════════════╝

Method    Path                    Controller#Action
------------------------------------------------------------
GET       /                       home#index
GET       /posts                 posts#index
POST      /posts                 posts#create
POST      /signup                auth#signup
POST      /login                 auth#login

Total: 5 route(s)
```

#### `kothari document`

Automatically generates and updates API documentation in the README.md file. This command parses all routes, extracts parameters from controllers, and generates comprehensive API documentation with request/response examples.

```bash
kothari document
```

**Features:**
- Lists all endpoints with HTTP methods and paths
- Extracts required parameters from controller actions
- Generates example request and response structures
- Updates README.md with auto-generated documentation section
- Prints documentation summary to terminal

**Output:**
```
╔═══════════════════════════════════════════════════════════╗
║                  API DOCUMENTATION                       ║
╚═══════════════════════════════════════════════════════════╝

Posts Endpoints:
  GET     /posts                          posts#index
  POST    /posts                          posts#create

Total: 2 endpoint(s) documented
✓ Documentation updated in README.md
```

The documentation section in README.md will be automatically updated with detailed endpoint information, parameters, and examples.

#### `kothari console`

Opens an interactive console for exploring your models and running SQL queries.

```bash
kothari console
```

**Note:** The console automatically installs shards if needed. Make sure you're in your KothariAPI app directory.

**Console Commands:**

#### `kothari diagram`

Generates a visual database schema diagram showing all tables, fields, and relationships.

```bash
kothari diagram
```

This command:
- Scans all migrations in `db/migrations/`
- Extracts table structures and field types
- Identifies relationships via `reference` fields (e.g., `user_id:reference`)
- Generates a Mermaid ER diagram saved to `db/diagram.md`

**Example:**

```bash
# Create models with references
kothari g model profile user_id:reference name:string bio:text
kothari g migration create_profiles user_id:reference name:string bio:text

# Generate diagram
kothari diagram
```

The diagram can be viewed in:
- GitHub (renders Mermaid automatically)
- VS Code (with Mermaid extension)
- Online at https://mermaid.live

**Reference Type:**

The `reference` type (or `ref`) creates a foreign key relationship:
- Creates an `INTEGER` field in the database
- Automatically adds an index for performance
- Tracks the relationship for diagram generation
- Example: `user_id:reference` creates `user_id INTEGER` with index

**Console Commands:**
```ruby
# List all models
models

# Query models
Post.all
Post.find(1)
Post.where("title = 'Hello'")

# Run SQL
sql SELECT * FROM posts

# Exit
exit
```

#### `kothari help` or `kothari`

Displays the help menu with all available commands.

```bash
kothari
kothari help
```

## Project Structure

```
myapp/
├── app/
│   ├── controllers/          # Application controllers
│   │   ├── home_controller.cr
│   │   └── posts_controller.cr
│   ├── models/               # Data models
│   │   └── post.cr
│   ├── controllers.cr        # Auto-loader for controllers
│   └── models.cr             # Auto-loader for models
├── config/
│   └── routes.cr             # Route definitions
├── db/
│   ├── migrations/           # Database migrations
│   └── development.sqlite3   # SQLite database
├── src/
│   └── server.cr             # HTTP server entry point
├── shard.yml                 # Dependencies
└── console.cr                # Console entry point
```

## Routing

Define routes in `config/routes.cr`:

```crystal
KothariAPI::Router::Router.draw do |r|
  r.get "/", to: "home#index"
  r.get "/posts", to: "posts#index"
  r.post "/posts", to: "posts#create"
  r.get "/posts/:id", to: "posts#show"
end
```

## Controllers

Controllers inherit from `KothariAPI::Controller` and provide a rich set of JSON helpers for different HTTP methods.

### Before Action & After Action Callbacks (Rails-style)

KothariAPI supports Rails-style `before_action` and `after_action` callbacks to run code before or after controller actions. This is perfect for authentication, setting up resources, logging, and more.

#### Basic Usage

```crystal
class PostsController < KothariAPI::Controller
  # Require authentication for all actions
  before_action :authenticate_user!

  # Or only for specific actions
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  
  # Or exclude specific actions
  before_action :authenticate_user!, except: [:index, :show]

  # Set up a resource before certain actions
  before_action :set_post, only: [:show, :update, :destroy]

  # Run code after actions
  after_action :log_action, only: [:create, :update, :destroy]

  def index
    json_get(Post.all)
  end

  def show
    # @post is set by set_post before_action
    json_get(@post)
  end

  def create
    attrs = permit_body("title", "content")
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      user_id: current_user_id  # Available because of authenticate_user!
    )
    json_post(post)
  end

  def update
    # @post is set by set_post before_action
    attrs = permit_body("title", "content")
    if Post.update(@post.id, attrs)
      json_update(Post.find(@post.id))
    else
      unprocessable_entity("Failed to update post")
    end
  end

  def destroy
    # @post is set by set_post before_action
    if Post.delete(@post.id)
      json_delete({message: "Post deleted successfully"})
    else
      internal_server_error("Failed to delete post")
    end
  end

  private

  # This method is called by before_action :authenticate_user!
  def authenticate_user!
    user = current_user
    unless user
      unauthorized("Authentication required")
      return false  # Stops the action from running
    end
    true
  end

  # This method is called by before_action :set_post
  def set_post
    id = params["id"]?.try &.to_i?
    @post = Post.find(id) if id
    unless @post
      not_found("Post not found")
      return false  # Stops the action from running
    end
    true
  end

  # This method is called by after_action :log_action
  def log_action
    # Log the action (e.g., to database or logging service)
    puts "Action performed: #{context.request.method} #{context.request.path}"
  end
end
```

#### Authentication Example

After running `kothari g auth`, you can protect your controllers like this:

```crystal
class PostsController < KothariAPI::Controller
  # Require authentication for create, update, destroy
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def index
    # Public - anyone can view posts
    json_get(Post.all)
  end

  def show
    # Public - anyone can view a post
    id = params["id"]?.try &.to_i?
    post = Post.find(id)
    if post
      json_get(post)
    else
      not_found("Post not found")
    end
  end

  def create
    # Protected - requires authentication
    # current_user is available because of authenticate_user!
    attrs = permit_body("title", "content")
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      user_id: current_user_id  # Uses the authenticated user's ID
    )
    json_post(post)
  end

  def update
    # Protected - requires authentication
    id = params["id"]?.try &.to_i?
    post = Post.find(id)
    return not_found("Post not found") unless post
    
    # Optional: Check if user owns the post
    unless post.user_id == current_user_id
      return forbidden("You can only update your own posts")
    end
    
    attrs = permit_body("title", "content")
    if Post.update(id, attrs)
      json_update(Post.find(id))
    else
      unprocessable_entity("Failed to update post")
    end
  end

  def destroy
    # Protected - requires authentication
    id = params["id"]?.try &.to_i?
    post = Post.find(id)
    return not_found("Post not found") unless post
    
    # Optional: Check if user owns the post
    unless post.user_id == current_user_id
      return forbidden("You can only delete your own posts")
    end
    
    if Post.delete(id)
      json_delete({message: "Post deleted successfully"})
    else
      internal_server_error("Failed to delete post")
    end
  end

  private

  # Built-in method - no need to define if using default behavior
  # Override if you need custom user lookup logic
  def authenticate_user!
    user = current_user
    unless user
      unauthorized("Authentication required")
      return false
    end
    true
  end
end
```

#### Setting Up Resources

Use `before_action` to set up resources that multiple actions need:

```crystal
class PostsController < KothariAPI::Controller
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :authenticate_user!, only: [:update, :destroy]

  def show
    # @post is already set by set_post
    json_get(@post)
  end

  def update
    # @post is already set, and user is authenticated
    attrs = permit_body("title", "content")
    if Post.update(@post.id, attrs)
      json_update(Post.find(@post.id))
    else
      unprocessable_entity("Failed to update post")
    end
  end

  private

  def set_post
    id = params["id"]?.try &.to_i?
    @post = Post.find(id) if id
    unless @post
      not_found("Post not found")
      return false
    end
    true
  end
end
```

#### Callback Options

**`only:`** - Run callback only for these actions
```crystal
before_action :authenticate_user!, only: [:create, :update, :destroy]
```

**`except:`** - Run callback for all actions except these
```crystal
before_action :authenticate_user!, except: [:index, :show]
```

**No options** - Run callback for all actions
```crystal
before_action :authenticate_user!
```

#### Built-in Authentication Helpers

KothariAPI provides these authentication helpers:

- `current_user` - Returns the authenticated user (from JWT token)
- `current_user_id` - Returns the authenticated user's ID (convenience method)
- `user_signed_in?` - Returns true if user is authenticated
- `authenticate_user!` - Stops the request if user is not authenticated (returns 401)

**Note:** `current_user_id` is a helper that returns `current_user.try &.id`. You can also use `current_user.id` directly, but `current_user_id` is safer as it handles nil cases.

#### Complete cURL Example: Creating a Post with JWT Authentication

Here's a complete example showing how to authenticate and create a post:

**Step 1: Sign up (or login) to get a JWT token**

```bash
# Sign up a new user
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

**Response:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "email": "user@example.com",
  "user_id": 1
}
```

**Step 2: Use the token to create a post**

```bash
# Create a post with JWT authentication
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -d '{
    "title": "My First Post",
    "content": "This is the content of my post"
  }'
```

**Or login if you already have an account:**

```bash
# Login to get a token
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

**Response:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "email": "user@example.com",
  "user_id": 1
}
```

**Step 3: Use the token in subsequent requests**

```bash
# Save the token to a variable (bash)
TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

# Create a post
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "My First Post",
    "content": "This is the content of my post"
  }'

# Update a post
curl -X PATCH http://localhost:3000/posts/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Updated Title",
    "content": "Updated content"
  }'

# Delete a post
curl -X DELETE http://localhost:3000/posts/1 \
  -H "Authorization: Bearer $TOKEN"

# Get all posts (public - no auth needed)
curl -X GET http://localhost:3000/posts

# Get a specific post (public - no auth needed)
curl -X GET http://localhost:3000/posts/1
```

#### How current_user.id Works

Yes, `current_user.id` works! Here's how it works in your controller:

```crystal
class PostsController < KothariAPI::Controller
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def create
    attrs = permit_body("title", "content")
    
    # Option 1: Use current_user_id (recommended - handles nil safely)
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      user_id: current_user_id  # Returns current_user.id or nil
    )
    
    # Option 2: Use current_user.id directly (if you're sure user exists)
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      user_id: current_user.not_nil!.id  # Direct access (use .not_nil! if sure)
    )
    
    # Option 3: Use current_user with safe navigation
    user = current_user
    if user
      post = Post.create(
        title: attrs["title"].to_s,
        content: attrs["content"].to_s,
        user_id: user.id  # Safe - we checked user exists
      )
    end
    
    json_post(post)
  end
end
```

**Recommended approach:** Use `current_user_id` because:
- It safely handles nil cases
- It's shorter and cleaner
- It works perfectly with `before_action :authenticate_user!` (which ensures user exists)

#### Complete Working Example

Here's a complete PostsController that works with JWT authentication:

```crystal
class PostsController < KothariAPI::Controller
  # Require authentication for create, update, destroy
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  
  # Make current_user work with User model
  private def find_user_by_id(user_id)
    User.find(user_id)
  end

  private def find_user_by_email(email : String)
    User.find_by("email", email)
  end

  def index
    # Public - no auth needed
    json_get(Post.all)
  end

  def show
    # Public - no auth needed
    id = params["id"]?.try &.to_i?
    post = Post.find(id)
    if post
      json_get(post)
    else
      not_found("Post not found")
    end
  end

  def create
    # Protected - requires JWT token
    # current_user and current_user_id are available here
    attrs = permit_body("title", "content")
    
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      user_id: current_user_id  # Automatically uses authenticated user's ID
    )
    
    json_post(post)
  end

  def update
    # Protected - requires JWT token
    id = params["id"]?.try &.to_i?
    post = Post.find(id)
    return not_found("Post not found") unless post
    
    # Optional: Check ownership
    unless post.user_id == current_user_id
      return forbidden("You can only update your own posts")
    end
    
    attrs = permit_body("title", "content")
    if Post.update(id, attrs)
      json_update(Post.find(id))
    else
      unprocessable_entity("Failed to update post")
    end
  end

  def destroy
    # Protected - requires JWT token
    id = params["id"]?.try &.to_i?
    post = Post.find(id)
    return not_found("Post not found") unless post
    
    # Optional: Check ownership
    unless post.user_id == current_user_id
      return forbidden("You can only delete your own posts")
    end
    
    if Post.delete(id)
      json_delete({message: "Post deleted successfully"})
    else
      internal_server_error("Failed to delete post")
    end
  end
end
```

#### Testing with cURL

**1. Sign up:**
```bash
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**2. Copy the token from the response, then create a post:**
```bash
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"title":"My Post","content":"Post content"}'
```

**3. Test without token (should fail with 401):**
```bash
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"My Post","content":"Post content"}'
```

**Expected error response:**
```json
{
  "error": "Authentication required"
}
```

#### Making current_user Work with Your User Model

After running `kothari g auth`, you need to override the helper methods in your controllers to make `current_user` work. Create an `ApplicationController` or add this to your base controller:

```crystal
# app/controllers/application_controller.cr (optional - create this file)
class ApplicationController < KothariAPI::Controller
  # Override these methods to make current_user work with your User model
  private def find_user_by_id(user_id)
    User.find(user_id)
  end

  private def find_user_by_email(email : String)
    User.find_by("email", email)
  end
end

# Then inherit from ApplicationController in your other controllers:
class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  # ... rest of your controller
end
```

Or, add the methods directly to each controller that needs authentication:

```crystal
class PostsController < KothariAPI::Controller
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  # ... your actions ...

  private

  # Make current_user work with User model
  def find_user_by_id(user_id)
    User.find(user_id)
  end

  def find_user_by_email(email : String)
    User.find_by("email", email)
  end
end
```

#### How It Works

1. **Before actions run first** - `before_action` callbacks run before the action method
2. **Return false to stop** - If a `before_action` returns `false`, the action won't run
3. **After actions run last** - `after_action` callbacks run after the action method completes
4. **Order matters** - Callbacks run in the order they're defined

#### Complete Example with Authentication

```crystal
class PostsController < KothariAPI::Controller
  # Authentication required for modifying posts
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  
  # Set post for show, update, destroy
  before_action :set_post, only: [:show, :update, :destroy]
  
  # Check ownership for update, destroy
  before_action :check_ownership!, only: [:update, :destroy]

  def index
    json_get(Post.all)
  end

  def show
    json_get(@post)
  end

  def create
    attrs = permit_body("title", "content")
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      user_id: current_user_id
    )
    json_post(post)
  end

  def update
    attrs = permit_body("title", "content")
    if Post.update(@post.id, attrs)
      json_update(Post.find(@post.id))
    else
      unprocessable_entity("Failed to update post")
    end
  end

  def destroy
    if Post.delete(@post.id)
      json_delete({message: "Post deleted successfully"})
    else
      internal_server_error("Failed to delete post")
    end
  end

  private

  def set_post
    id = params["id"]?.try &.to_i?
    @post = Post.find(id) if id
    unless @post
      not_found("Post not found")
      return false
    end
    true
  end

  def check_ownership!
    unless @post.user_id == current_user_id
      forbidden("You can only modify your own posts")
      return false
    end
    true
  end
end
```

This example shows:
- Public `index` and `show` actions (no authentication)
- Protected `create`, `update`, `destroy` actions (require authentication)
- Resource setup with `set_post`
- Ownership checking with `check_ownership!`

### JSON Response Helpers

KothariAPI provides convenient JSON helpers for each HTTP method:

#### `json_get(data)` - GET Requests
Returns 200 OK with JSON data. Use for listing and showing resources.

```crystal
def index
  json_get(Post.all)  # Returns 200 OK
end

def show
  post = Post.find(params["id"]?.try &.to_i?)
  if post
    json_get(post)  # Returns 200 OK
  else
    not_found("Post not found")
  end
end
```

#### `json_post(data)` - POST Requests
Returns 201 Created with JSON data. Use for creating new resources.

```crystal
def create
  attrs = permit_body("title", "content")
  post = Post.create(
    title: attrs["title"].to_s,
    content: attrs["content"].to_s
  )
  json_post(post)  # Returns 201 Created
end
```

#### `json_update(data)` - PUT/PATCH Requests
Returns 200 OK with JSON data. Use for updating existing resources.

```crystal
def update
  id = params["id"]?.try &.to_i?
  post = Post.find(id)
  return not_found("Post not found") unless post
  
  attrs = permit_body("title", "content")
  if Post.update(id, attrs)
    json_update(Post.find(id))  # Returns 200 OK
  else
    unprocessable_entity("Failed to update post")
  end
end
```

#### `json_patch(data)` - PATCH Requests
Alias for `json_update`. Returns 200 OK with JSON data.

```crystal
def update
  # ... same as above
  json_patch(Post.find(id))  # Returns 200 OK
end
```

#### `json_delete(data)` - DELETE Requests
Returns 200 OK with JSON data, or 204 No Content if no data provided.

```crystal
def destroy
  id = params["id"]?.try &.to_i?
  if Post.delete(id)
    json_delete({message: "Post deleted successfully"})  # Returns 200 OK
    # Or simply:
    # json_delete  # Returns 204 No Content
  else
    not_found("Post not found")
  end
end
```

#### `json(data)` - Generic JSON Response
Generic helper that sets content-type but doesn't set status code. Use when you need custom status codes.

```crystal
def custom_action
  context.response.status = HTTP::Status::ACCEPTED
  json({message: "Request accepted"})
end
```

### Complete Controller Example

```crystal
class PostsController < KothariAPI::Controller
  # GET /posts
  def index
    json_get(Post.all)
  end

  # GET /posts/:id
  def show
    id = params["id"]?.try &.to_i?
    post = Post.find(id)
    if post
      json_get(post)
    else
      not_found("Post not found")
    end
  end

  # POST /posts
  def create
    attrs = permit_body("title", "content", "published")
    begin
      post = Post.create(
        title: attrs["title"].to_s,
        content: attrs["content"].to_s,
        published: attrs["published"]?.as_bool? || false
      )
      json_post(post)
    rescue ex
      unprocessable_entity("Failed to create post", {
        "details" => JSON::Any.new(ex.message || "Unknown error")
      })
    end
  end

  # PATCH /posts/:id
  def update
    id = params["id"]?.try &.to_i?
    return bad_request("ID required") unless id
    
    post = Post.find(id)
    return not_found("Post not found") unless post
    
    attrs = permit_body("title", "content", "published")
    begin
      if Post.update(id, attrs)
        json_update(Post.find(id))
      else
        unprocessable_entity("Failed to update post")
      end
    rescue ex
      unprocessable_entity("Failed to update post", {
        "details" => JSON::Any.new(ex.message || "Unknown error")
      })
    end
  end

  # DELETE /posts/:id
  def destroy
    id = params["id"]?.try &.to_i?
    return bad_request("ID required") unless id
    
    post = Post.find(id)
    return not_found("Post not found") unless post
    
    begin
      if Post.delete(id)
        json_delete({message: "Post deleted successfully"})
      else
        internal_server_error("Failed to delete post")
      end
    rescue ex
      internal_server_error("Failed to delete post", {
        "details" => JSON::Any.new(ex.message || "Unknown error")
      })
    end
  end

  private def post_params
    permit_body("title", "content", "published")
  end
end

KothariAPI::ControllerRegistry.register("posts", PostsController)
```

### Error Response Helpers

KothariAPI provides standardized error response helpers:

```crystal
bad_request("Invalid input")                    # 400 Bad Request
unauthorized("Authentication required")         # 401 Unauthorized
forbidden("Access denied")                      # 403 Forbidden
not_found("Resource not found")                 # 404 Not Found
unprocessable_entity("Validation failed")       # 422 Unprocessable Entity
internal_server_error("Server error")           # 500 Internal Server Error
```

All error helpers accept an optional `details` hash for additional information:

```crystal
bad_request("Validation failed", {
  "field" => JSON::Any.new("email"),
  "message" => JSON::Any.new("Invalid email format")
})
```

## JSON Helpers Reference

KothariAPI provides convenient JSON response helpers for all HTTP methods. These helpers automatically set the correct status codes and content types.

### GET Requests - `json_get(data)`

Returns **200 OK** with JSON data. Perfect for `index` and `show` actions.

```crystal
def index
  json_get(Post.all)  # 200 OK
end

def show
  post = Post.find(params["id"]?.try &.to_i?)
  if post
    json_get(post)  # 200 OK
  else
    not_found("Post not found")
  end
end
```

### POST Requests - `json_post(data)`

Returns **201 Created** with JSON data. Use for creating new resources.

```crystal
def create
  attrs = permit_body("title", "content")
  post = Post.create(
    title: attrs["title"].to_s,
    content: attrs["content"].to_s
  )
  json_post(post)  # 201 Created
end
```

### UPDATE/PATCH Requests - `json_update(data)` / `json_patch(data)`

Returns **200 OK** with JSON data. Use for updating existing resources.

```crystal
def update
  id = params["id"]?.try &.to_i?
  post = Post.find(id)
  return not_found("Post not found") unless post
  
  attrs = permit_body("title", "content")
  if Post.update(id, attrs)
    json_update(Post.find(id))  # 200 OK
    # Or use json_patch for PATCH requests
    # json_patch(Post.find(id))
  else
    unprocessable_entity("Failed to update post")
  end
end
```

### DELETE Requests - `json_delete(data)`

Returns **200 OK** with JSON data, or **204 No Content** if no data provided.

```crystal
def destroy
  id = params["id"]?.try &.to_i?
  if Post.delete(id)
    json_delete({message: "Post deleted successfully"})  # 200 OK
    # Or for 204 No Content:
    # json_delete
  else
    not_found("Post not found")
  end
end
```

### Generic JSON Response - `json(data)`

Generic helper that sets content-type but doesn't set status code. Use when you need custom status codes.

```crystal
def custom_action
  context.response.status = HTTP::Status::ACCEPTED
  json({message: "Request accepted"})
end
```

### Request Parameters

#### Query Parameters

Access query string parameters using `params`:

```crystal
def index
  page = params["page"]?.try &.to_i? || 1
  limit = params["limit"]?.try &.to_i? || 10
  # Use page and limit for pagination
end
```

#### Path Parameters

Path parameters from routes like `/posts/:id` are automatically available in `params`:

```crystal
# Route: GET /posts/:id
def show
  id = params["id"]?.try &.to_i?  # Automatically extracted from path
  post = Post.find(id)
  # ...
end
```

#### JSON Body Parameters

Access JSON request body using `json_body` or use strong params with `permit_body`:

```crystal
def create
  # Get all JSON body data
  data = json_body
  
  # Or use strong params (recommended)
  attrs = permit_body("title", "content", "published")
  # Only "title", "content", and "published" are allowed
end
```

#### Strong Parameters

Use `permit_body` for JSON body parameters and `permit_params` for query parameters:

```crystal
# Only allow specific fields from JSON body
def create
  attrs = permit_body("title", "content", "published")
  post = Post.create(
    title: attrs["title"].to_s,
    content: attrs["content"].to_s,
    published: attrs["published"]?.as_bool? || false
  )
end

# Only allow specific query parameters
def index
  filters = permit_params("status", "category")
  # Use filters safely
end
```

## Models

Models inherit from `KothariAPI::Model`:

```crystal
class Post < KothariAPI::Model
  table "posts"

  @title : String
  @content : String
  @created_at : String?
  @updated_at : String?

  def initialize(@title : String, @content : String, 
                 @created_at : String? = nil, @updated_at : String? = nil)
  end

  KothariAPI::ModelRegistry.register("post", Post)
end
```

**Model Methods:**
- `Post.all` - Get all records
- `Post.find(id)` - Find by ID
- `Post.create(**fields)` - Create a new record
- `Post.update(id, attrs)` - Update a record by ID
- `Post.delete(id)` - Delete a record by ID
- `Post.where(condition)` - Query with SQL condition
- `Post.find_by(column, value)` - Find by a specific column

## Data Types

KothariAPI supports the following data types:

| CLI Type | Crystal Type | SQL Type | Example |
|----------|--------------|----------|---------|
| `string`, `text` | `String` | `TEXT` | `name:string` |
| `int`, `integer` | `Int32` | `INTEGER` | `age:int` |
| `bigint`, `int64` | `Int64` | `INTEGER` | `views:bigint` |
| `float`, `double` | `Float64` | `REAL` | `price:float` |
| `bool`, `boolean` | `Bool` | `INTEGER` | `active:bool` |
| `json`, `json::any` | `JSON::Any` | `TEXT` | `metadata:json` |
| `time`, `datetime`, `timestamp` | `Time` | `TEXT` | `created:time` |
| `uuid` | `String` | `TEXT` | `id:uuid` |

## Authentication

KothariAPI includes built-in JWT-based authentication:

```bash
# Generate auth
kothari g auth
kothari db:migrate
```

**Usage:**
```crystal
# Signup
POST /signup
{
  "email": "user@example.com",
  "password": "password123"
}

# Login (returns JWT token)
POST /login
{
  "email": "user@example.com",
  "password": "password123"
}
```

## CORS Configuration

CORS (Cross-Origin Resource Sharing) controls which applications/domains can access your API from a browser. This is a critical security feature that prevents unauthorized websites from making requests to your API.

### Configuration File

KothariAPI uses `config/initializers/cors.cr` (similar to Rails' `config/initializers/cors.rb`) to configure CORS settings.

**Location:** `config/initializers/cors.cr`

### Understanding CORS Settings

#### `allowed_origins`

**What it does:** Specifies which domains/URLs are allowed to make requests to your API.

**Options:**
- **Specific domains:** `["https://example.com", "https://app.example.com"]` - Only these domains can access your API
- **Wildcard:** `["*"]` - Allows ALL domains (⚠️ **NOT recommended for production** - security risk)
- **Empty array:** `[]` - Disables CORS completely

**Example:**
```crystal
allowed_origins: [
  "http://localhost:3000",        # Local development
  "http://localhost:5173",        # Vite dev server
  "https://myapp.com",            # Production domain
  "https://app.myapp.com"         # Subdomain
]
```

**Why it matters:** Without this, browsers will block requests from your frontend to your API due to the Same-Origin Policy.

---

#### `allowed_methods`

**What it does:** Specifies which HTTP methods (GET, POST, etc.) are allowed.

**Options:**
- `"GET"` - Fetch/read data
- `"POST"` - Create new resources
- `"PUT"` - Update entire resource
- `"PATCH"` - Partially update resource
- `"DELETE"` - Delete resources
- `"OPTIONS"` - Preflight requests (required for CORS)

**Example:**
```crystal
allowed_methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
```

**Why it matters:** Restricts which HTTP operations clients can perform. Only include methods your API actually uses.

---

#### `allowed_headers`

**What it does:** Specifies which request headers clients are allowed to send.

**Common headers:**
- `"Content-Type"` - Required for JSON requests (`application/json`)
- `"Authorization"` - Required for JWT tokens and authentication
- `"Accept"` - What content types the client accepts
- `"X-Requested-With"` - Used by some frameworks

**Example:**
```crystal
allowed_headers: [
  "Content-Type",
  "Authorization",
  "Accept",
  "X-Requested-With",
  "X-Custom-Header"  # Your custom headers
]
```

**Why it matters:** Browsers will block requests with headers not in this list. Add any custom headers your API needs.

---

#### `exposed_headers`

**What it does:** Specifies which response headers JavaScript can read in the browser.

**When to use:**
- If your API returns custom headers that the frontend needs to read
- Examples: `"X-Total-Count"`, `"X-Page-Number"`, `"X-Rate-Limit-Remaining"`

**Example:**
```crystal
exposed_headers: [
  "X-Total-Count",
  "X-Page-Number",
  "X-Rate-Limit-Remaining"
]
```

**Why it matters:** By default, browsers only expose a few headers to JavaScript. This lets you expose custom headers.

---

#### `max_age`

**What it does:** How long (in seconds) browsers can cache preflight OPTIONS responses.

**Options:**
- `3600` - 1 hour (default, good balance)
- `86400` - 24 hours (reduces preflight requests)
- `0` - No caching (browser checks every time)

**Example:**
```crystal
max_age: 3600  # Cache for 1 hour
```

**Why it matters:** Preflight requests add latency. Caching reduces the number of preflight requests, improving performance.

---

#### `allow_credentials`

**What it does:** Whether to allow cookies and authentication headers in cross-origin requests.

**Options:**
- `false` - More secure, doesn't allow credentials (default)
- `true` - Allows cookies/auth headers (⚠️ requires specific origins, cannot use `"*"`)

**Example:**
```crystal
allow_credentials: false  # Default, more secure
```

**Important:** If `allow_credentials: true`, you **MUST** specify exact origins (cannot use `"*"`).

**Why it matters:** Credentials include cookies and authentication headers. Only enable if you need them.

---

### Complete CORS Configuration Example

```crystal
# config/initializers/cors.cr

KothariAPI::CORS.configure(
  # Development: Allow localhost
  # Production: Only your actual domains
  allowed_origins: [
    "http://localhost:3000",
    "http://localhost:5173",
    "https://myapp.com",
    "https://app.myapp.com"
  ],

  # All standard REST methods
  allowed_methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],

  # Standard headers for JSON API
  allowed_headers: [
    "Content-Type",
    "Authorization",
    "Accept",
    "X-Requested-With"
  ],

  # Expose pagination headers to frontend
  exposed_headers: [
    "X-Total-Count",
    "X-Page-Number"
  ],

  # Cache preflight for 1 hour
  max_age: 3600,

  # Don't allow credentials (more secure)
  allow_credentials: false
)
```

### Development vs Production

**Development:**
```crystal
allowed_origins: [
  "http://localhost:3000",
  "http://localhost:5173",
  "http://127.0.0.1:3000"
]
```

**Production:**
```crystal
allowed_origins: [
  "https://yourdomain.com",
  "https://app.yourdomain.com"
]
# NEVER use "*" in production!
```

### Testing CORS

**Test from browser console:**
```javascript
fetch('http://localhost:3000/api/posts', {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_TOKEN'
  }
})
.then(response => response.json())
.then(data => console.log(data))
.catch(error => console.error('CORS Error:', error));
```

**Common CORS Errors:**
- `Access-Control-Allow-Origin` missing → Add origin to `allowed_origins`
- `Access-Control-Allow-Methods` missing → Add method to `allowed_methods`
- `Access-Control-Allow-Headers` missing → Add header to `allowed_headers`
- Credentials error → Set `allow_credentials: true` and use specific origins

### Security Best Practices

1. ✅ **Never use `"*"` in production** - Always specify exact domains
2. ✅ **Use HTTPS in production** - Always use `https://` for production origins
3. ✅ **Minimize allowed methods** - Only include methods you actually use
4. ✅ **Minimize allowed headers** - Only include headers you need
5. ✅ **Use specific origins** - Don't allow wildcards in production
6. ✅ **Review regularly** - Remove unused origins and headers

### Disabling CORS

To disable CORS completely:
```crystal
KothariAPI::CORS.configure(
  allowed_origins: []  # Empty array disables CORS
)
```

Or simply don't require the CORS config file in `server.cr`.

## ASCII Art Banners

Every command displays a beautiful ASCII art banner with the command name:

```bash
kothari new myapp      # Shows "NEW" banner
kothari db:migrate     # Shows "MIGRATE" banner
kothari routes         # Shows "ROUTES" banner
kothari help           # Shows "HELP" banner
```

## Fetching External APIs

KothariAPI makes it easy to fetch data from external APIs and return it using JSON helpers. Crystal's built-in `HTTP::Client` is perfect for this.

### Quick Reference Pattern

```crystal
require "http/client"
require "json"

class ApiController < KothariAPI::Controller
  def index
    begin
      # 1. Make HTTP request
      response = HTTP::Client.get("https://api.example.com/data")
      
      # 2. Check status code
      return internal_server_error("API error") unless response.status_code == 200
      
      # 3. Parse JSON
      data = JSON.parse(response.body)
      
      # 4. Return using JSON helper
      json_get(data)  # For GET requests
      # json_post(data)   # For POST requests (201 Created)
      # json_update(data) # For PUT/PATCH requests (200 OK)
      # json_delete(data) # For DELETE requests (200 OK or 204 No Content)
    rescue ex
      internal_server_error("Error: #{ex.message}")
    end
  end
end
```

### Basic Example: Fetching and Returning API Data

```crystal
require "http/client"
require "json"

class WeatherController < KothariAPI::Controller
  # GET /weather/:city
  # Fetches weather data from an external API and returns it
  def show
    city = params["city"]?.to_s
    return bad_request("City parameter required") unless city
    
    begin
      # Fetch data from external API
      response = HTTP::Client.get("https://api.weather.example.com/weather?city=#{city}")
      
      unless response.status_code == 200
        return internal_server_error("Failed to fetch weather data")
      end
      
      # Parse JSON response
      weather_data = JSON.parse(response.body)
      
      # Return using json_get helper (200 OK)
      json_get(weather_data)
    rescue ex : HTTP::Client::Error
      internal_server_error("Network error: #{ex.message}")
    rescue ex : JSON::ParseException
      internal_server_error("Invalid JSON response from API")
    rescue ex
      internal_server_error("Unexpected error: #{ex.message}")
    end
  end
end

KothariAPI::ControllerRegistry.register("weather", WeatherController)
```

### Advanced Example: POST to External API

```crystal
require "http/client"
require "json"

class PaymentController < KothariAPI::Controller
  # POST /payments
  # Creates a payment by calling an external payment API
  def create
    attrs = permit_body("amount", "currency", "description")
    
    # Validate required fields
    unless attrs["amount"]? && attrs["currency"]?
      return unprocessable_entity("Amount and currency are required")
    end
    
    begin
      # Prepare request to external API
      payment_data = {
        "amount" => attrs["amount"].as_f? || attrs["amount"].to_s.to_f,
        "currency" => attrs["currency"].to_s,
        "description" => attrs["description"]?.to_s || ""
      }
      
      # Make POST request to external payment API
      response = HTTP::Client.post(
        "https://api.payment.example.com/charges",
        headers: HTTP::Headers{
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{ENV["PAYMENT_API_KEY"]? || ""}"
        },
        body: payment_data.to_json
      )
      
      case response.status_code
      when 200, 201
        # Parse successful response
        payment_result = JSON.parse(response.body)
        
        # Save to database (optional)
        payment = Payment.create(
          amount: payment_data["amount"],
          currency: payment_data["currency"],
          external_id: payment_result["id"]?.to_s,
          status: payment_result["status"]?.to_s || "pending"
        )
        
        # Return using json_post helper (201 Created)
        json_post({
          "id" => payment.id,
          "amount" => payment.amount,
          "currency" => payment.currency,
          "status" => payment.status,
          "external_response" => payment_result
        })
      when 400
        error_data = JSON.parse(response.body)
        bad_request("Payment failed", {
          "details" => error_data
        })
      when 401
        unauthorized("Invalid API credentials")
      else
        internal_server_error("Payment service error")
      end
    rescue ex : HTTP::Client::Error
      internal_server_error("Network error: #{ex.message}")
    rescue ex
      internal_server_error("Unexpected error: #{ex.message}")
    end
  end
end

KothariAPI::ControllerRegistry.register("payments", PaymentController)
```

### Example: Fetching Multiple APIs and Aggregating Data

```crystal
require "http/client"
require "json"

class DashboardController < KothariAPI::Controller
  # GET /dashboard
  # Fetches data from multiple APIs and combines them
  def index
    begin
      # Fetch from multiple APIs in parallel (using fibers)
      user_data = fetch_user_data
      stats_data = fetch_statistics
      notifications = fetch_notifications
      
      # Combine all data
      dashboard_data = {
        "user" => user_data,
        "statistics" => stats_data,
        "notifications" => notifications,
        "timestamp" => Time.utc.to_s
      }
      
      # Return using json_get helper (200 OK)
      json_get(dashboard_data)
    rescue ex
      internal_server_error("Failed to load dashboard: #{ex.message}")
    end
  end
  
  private def fetch_user_data
    response = HTTP::Client.get(
      "https://api.example.com/user",
      headers: HTTP::Headers{"Authorization" => "Bearer #{get_auth_token}"}
    )
    JSON.parse(response.body) if response.status_code == 200
  end
  
  private def fetch_statistics
    response = HTTP::Client.get("https://api.example.com/stats")
    JSON.parse(response.body) if response.status_code == 200
  end
  
  private def fetch_notifications
    response = HTTP::Client.get(
      "https://api.example.com/notifications",
      headers: HTTP::Headers{"Authorization" => "Bearer #{get_auth_token}"}
    )
    JSON.parse(response.body) if response.status_code == 200
  end
  
  private def get_auth_token
    # Extract token from request headers
    context.request.headers["Authorization"]?.try &.lchop("Bearer ").strip || ""
  end
end

KothariAPI::ControllerRegistry.register("dashboard", DashboardController)
```

### Example: Updating External Resource

```crystal
require "http/client"
require "json"

class SyncController < KothariAPI::Controller
  # PATCH /sync/:id
  # Updates a resource in external API and local database
  def update
    id = params["id"]?.try &.to_i?
    return bad_request("ID required") unless id
    
    attrs = permit_body("name", "status")
    
    begin
      # Update external API first
      update_data = {
        "name" => attrs["name"]?.to_s || "",
        "status" => attrs["status"]?.to_s || ""
      }
      
      response = HTTP::Client.patch(
        "https://api.example.com/resources/#{id}",
        headers: HTTP::Headers{
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{ENV["API_KEY"]?}"
        },
        body: update_data.to_json
      )
      
      unless response.status_code == 200
        return unprocessable_entity("Failed to update external resource")
      end
      
      # Update local database
      external_data = JSON.parse(response.body)
      local_resource = Resource.find(id)
      
      if local_resource && Resource.update(id, {
        "name" => JSON::Any.new(external_data["name"]?.to_s || ""),
        "status" => JSON::Any.new(external_data["status"]?.to_s || ""),
        "synced_at" => JSON::Any.new(Time.utc.to_s)
      })
        # Return using json_update helper (200 OK)
        json_update(Resource.find(id))
      else
        unprocessable_entity("Failed to update local resource")
      end
    rescue ex
      internal_server_error("Sync error: #{ex.message}")
    end
  end
end

KothariAPI::ControllerRegistry.register("sync", SyncController)
```

### Example: DELETE from External API

```crystal
require "http/client"

class ResourceController < KothariAPI::Controller
  # DELETE /resources/:id
  # Deletes resource from external API and local database
  def destroy
    id = params["id"]?.try &.to_i?
    return bad_request("ID required") unless id
    
    begin
      # Delete from external API
      response = HTTP::Client.delete(
        "https://api.example.com/resources/#{id}",
        headers: HTTP::Headers{"Authorization" => "Bearer #{ENV["API_KEY"]?}"}
      )
      
      unless response.status_code == 200 || response.status_code == 204
        return internal_server_error("Failed to delete from external API")
      end
      
      # Delete from local database
      if Resource.delete(id)
        # Return using json_delete helper (200 OK with message)
        json_delete({message: "Resource deleted successfully"})
      else
        internal_server_error("Failed to delete local resource")
      end
    rescue ex
      internal_server_error("Delete error: #{ex.message}")
    end
  end
end

KothariAPI::ControllerRegistry.register("resources", ResourceController)
```

### Best Practices for API Fetching

1. **Always handle errors**: Wrap API calls in `begin/rescue` blocks
2. **Use appropriate JSON helpers**: Choose the right helper based on the operation
3. **Set proper headers**: Include authentication and content-type headers
4. **Validate responses**: Check status codes before processing
5. **Parse JSON safely**: Handle JSON parsing errors gracefully
6. **Use environment variables**: Store API keys in environment variables, not in code

### Complete Example: Weather API Proxy

```crystal
require "http/client"
require "json"

class WeatherController < KothariAPI::Controller
  # GET /weather
  # Proxies weather API with caching
  def index
    city = params["city"]?.to_s
    return bad_request("City parameter required") unless city
    
    # Check cache first (optional)
    cached = WeatherCache.find_by_city(city)
    if cached && !cached.expired?
      return json_get(cached.data)
    end
    
    begin
      # Fetch from external API
      api_key = ENV["WEATHER_API_KEY"]? || raise "WEATHER_API_KEY not set"
      
      response = HTTP::Client.get(
        "https://api.openweathermap.org/data/2.5/weather?q=#{city}&appid=#{api_key}",
        headers: HTTP::Headers{"Accept" => "application/json"}
      )
      
      case response.status_code
      when 200
        weather_data = JSON.parse(response.body)
        
        # Cache the result (optional)
        WeatherCache.create_or_update(city, weather_data)
        
        # Return using json_get helper
        json_get(weather_data)
      when 404
        not_found("City not found")
      when 401
        unauthorized("Invalid API key")
      else
        internal_server_error("Weather service unavailable")
      end
    rescue ex : KeyError
      internal_server_error("API key not configured")
    rescue ex : HTTP::Client::Error
      internal_server_error("Network error: #{ex.message}")
    rescue ex
      internal_server_error("Unexpected error: #{ex.message}")
    end
  end
end

KothariAPI::ControllerRegistry.register("weather", WeatherController)
```

## Examples

### Complete Blog API

```bash
# Create app
kothari new blog_api
cd blog_api
shards install

# Generate scaffold
kothari g scaffold post title:string content:text published:bool

# Generate auth
kothari g auth

# Run migrations
kothari db:migrate

# Start server
kothari server -p 3000
```

**API Endpoints:**
- `GET /posts` - List all posts
- `POST /posts` - Create a post
- `POST /signup` - Register user
- `POST /login` - Login user

### E-commerce API

```bash
kothari new shop_api
cd shop_api
shards install

# Products with JSON metadata
kothari g scaffold product \
  name:string \
  price:float \
  metadata:json \
  created:time

kothari db:migrate
kothari server
```

## Production Readiness

KothariAPI is designed with production use in mind:

### Security Features

- **SQL Injection Protection**: All database queries use parameterized statements
- **Strong Parameters**: Built-in support for whitelisting allowed parameters
- **Type Safety**: Crystal's type system prevents many runtime errors
- **Error Handling**: Comprehensive error handling with proper HTTP status codes

### Performance

- **Compiled Language**: Crystal compiles to native code for maximum performance
- **Efficient Database Queries**: Uses parameterized queries and connection pooling
- **Minimal Overhead**: Lightweight framework with minimal abstraction layers

### Best Practices

1. **Always use strong parameters** (`permit_body`, `permit_params`) to prevent mass assignment
2. **Handle errors gracefully** using the provided error response helpers
3. **Use appropriate HTTP status codes** with the JSON helper methods
4. **Validate input** before processing requests
5. **Use transactions** for complex database operations (when needed)

### Example: Production-Ready Controller

```crystal
class PostsController < KothariAPI::Controller
  def index
    json_get(Post.all)
  end

  def show
    id = params["id"]?.try &.to_i?
    return bad_request("Invalid ID") unless id
    
    post = Post.find(id)
    return not_found("Post not found") unless post
    
    json_get(post)
  end

  def create
    attrs = permit_body("title", "content", "published")
    
    # Validate required fields
    unless attrs["title"]?
      return unprocessable_entity("Title is required")
    end
    
    begin
      post = Post.create(
        title: attrs["title"].to_s,
        content: attrs["content"]?.to_s || "",
        published: attrs["published"]?.as_bool? || false
      )
      json_post(post)
    rescue ex
      unprocessable_entity("Failed to create post", {
        "details" => JSON::Any.new(ex.message || "Unknown error")
      })
    end
  end

  def update
    id = params["id"]?.try &.to_i?
    return bad_request("Invalid ID") unless id
    
    post = Post.find(id)
    return not_found("Post not found") unless post
    
    attrs = permit_body("title", "content", "published")
    begin
      if Post.update(id, attrs)
        json_update(Post.find(id))
      else
        unprocessable_entity("Failed to update post")
      end
    rescue ex
      unprocessable_entity("Failed to update post", {
        "details" => JSON::Any.new(ex.message || "Unknown error")
      })
    end
  end

  def destroy
    id = params["id"]?.try &.to_i?
    return bad_request("Invalid ID") unless id
    
    post = Post.find(id)
    return not_found("Post not found") unless post
    
    begin
      if Post.delete(id)
        json_delete({message: "Post deleted successfully"})
      else
        internal_server_error("Failed to delete post")
      end
    rescue ex
      internal_server_error("Failed to delete post", {
        "details" => JSON::Any.new(ex.message || "Unknown error")
      })
    end
  end
end
```

## Development

### Running Tests

```bash
# Build the framework
crystal build src/cli/kothari.cr -o kothari

# Test in a new app
kothari new test_app
cd test_app
shards install
kothari server
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

- GitHub Issues: [https://github.com/backlinkedclub/kothari_api/issues](https://github.com/backlinkedclub/kothari_api/issues)
- Documentation: See this README

## Version

Current Version: **1.0.0**

---

**Built with ❤️ using Crystal**
