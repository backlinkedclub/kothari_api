# KothariAPI Framework - Complete Guide

**Version 1.5.0** - Comprehensive documentation for all commands, features, and functions.

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [App Management Commands](#app-management-commands)
4. [Server Commands](#server-commands)
5. [Generator Commands](#generator-commands)
6. [Database Commands](#database-commands)
7. [Utility Commands](#utility-commands)
8. [Controller Functions](#controller-functions)
9. [Model Functions](#model-functions)
10. [Authentication](#authentication)
11. [Reference Type Feature](#reference-type-feature)
12. [Database Diagram Feature](#database-diagram-feature)
13. [Advanced Examples](#advanced-examples)

---

## Installation

### Prerequisites

- **Crystal 1.0 or higher** - [Install Crystal](https://crystal-lang.org/install/)
- **SQLite3** - Usually pre-installed on Linux/Mac

### Step-by-Step Installation

```bash
# 1. Clone the repository
git clone https://github.com/backlinkedclub/kothari_api.git
cd kothari_api

# 2. Install dependencies
shards install

# 3. Build the CLI binary
crystal build src/cli/kothari.cr -o kothari

# 4. (Optional) Install globally
sudo cp kothari /usr/local/bin/kothari
# OR
sudo mv kothari /usr/local/bin/kothari

# 5. Verify installation
kothari help
```

**Important:** After cloning, you MUST rebuild the binary to get the latest features:
```bash
crystal build src/cli/kothari.cr -o kothari
```

---

## Quick Start

```bash
# 1. Create a new application
kothari new myapp
cd myapp

# 2. Install dependencies
shards install

# 3. Generate a scaffold (model + controller + migration + routes)
kothari g scaffold post title:string content:text published:bool

# 4. Run database migrations
kothari db:migrate

# 5. Start the development server
kothari server

# 6. Test your API
curl http://localhost:3000/posts
```

---

## App Management Commands

### `kothari new <app_name>`

Creates a new KothariAPI application with the complete directory structure.

**Usage:**
```bash
kothari new blog_api
cd blog_api
shards install
```

**What it creates:**
```
blog_api/
├── app/
│   ├── controllers/
│   │   ├── home_controller.cr
│   │   └── controllers.cr
│   └── models/
│       └── models.cr
├── config/
│   ├── routes.cr
│   └── initializers/
│       └── cors.cr
├── db/
│   └── migrations/
├── public/
├── src/
│   └── server.cr
├── shard.yml
└── shard.lock
```

**Generated Files:**
- `app/controllers/home_controller.cr` - Default home controller
- `config/routes.cr` - Route definitions
- `src/server.cr` - Main server file
- `shard.yml` - Dependencies configuration

**Next Steps:**
```bash
cd blog_api
shards install
kothari server
```

---

## Server Commands

### `kothari server [-p|--port PORT]`

Starts the development server. The server automatically:
- Finds an available port if the default is in use
- Installs shards if missing
- Handles CORS
- Serves static files from `public/` directory

**Usage:**
```bash
# Default port (3000)
kothari server

# Custom port
kothari server -p 3001
kothari server --port 5000

# Using environment variable
export KOTHARI_PORT=4000
kothari server
```

**Server Features:**
- Automatic port detection (tries next port if 3000 is busy)
- Auto-shard installation
- CORS support (configurable in `config/initializers/cors.cr`)
- Static file serving from `public/` directory
- Error handling with proper HTTP status codes

**Output:**
```
Running on http://localhost:3000
```

**Stopping the Server:**
Press `Ctrl+C` to stop the server.

### `kothari build [output] [--release]`

Compiles your application into a standalone binary.

**Usage:**
```bash
# Build with default name (app directory name)
kothari build

# Build with custom name
kothari build myapp

# Build optimized release version
kothari build myapp --release
```

**Examples:**
```bash
# Development build
kothari build blog_api

# Production build (optimized)
kothari build blog_api --release

# Run the binary
./blog_api
```

**What it does:**
- Compiles `src/server.cr` into a binary
- Includes all dependencies
- Creates a standalone executable

---

## Generator Commands

### `kothari g model <name> [field:type ...]`

Generates a new model class with optional fields.

**Usage:**
```bash
# Simple model (no fields)
kothari g model user

# Model with fields
kothari g model article title:string content:text views:integer published:bool
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
- `reference`, `ref` → `Int32` (creates foreign key with index)

**Example:**
```bash
kothari g model post title:string content:text views:integer published:bool
```

**Generated File:** `app/models/post.cr`
```crystal
class Post < KothariAPI::Model
  table "posts"

  @id : Int64?
  @title : String
  @content : String
  @views : Int32
  @published : Bool
  @created_at : String?
  @updated_at : String?

  property id : Int64?
  property title : String
  property content : String
  property views : Int32
  property published : Bool
  property created_at : String?
  property updated_at : String?

  def initialize(@title : String, @content : String, @views : Int32, @published : Bool, @created_at : String? = nil, @updated_at : String? = nil, @id : Int64? = nil)
  end

  KothariAPI::ModelRegistry.register("post", Post)
end
```

**Next Step:** Create a migration to create the database table:
```bash
kothari g migration create_posts title:string content:text views:integer published:bool
kothari db:migrate
```

### `kothari g migration <name> [field:type ...]`

Generates a database migration file.

**Usage:**
```bash
# Create table migration
kothari g migration create_users email:string password_digest:string

# Migration with reference type (creates foreign key + index)
kothari g migration create_profiles user_id:reference name:string bio:text
```

**Migration Naming:**
- `create_<table>` - Creates a new table
- Any other name - Custom migration

**Example:**
```bash
kothari g migration create_posts title:string content:text views:integer
```

**Generated File:** `db/migrations/<timestamp>_create_posts.sql`
```sql
CREATE TABLE IF NOT EXISTS posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  content TEXT,
  views INTEGER,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**With Reference Type:**
```bash
kothari g migration create_comments post_id:reference content:text
```

**Generated:**
```sql
CREATE TABLE IF NOT EXISTS comments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER,
  content TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
```

**Running Migrations:**
```bash
kothari db:migrate
```

### `kothari g controller <name>`

Generates a new controller with an `index` action and route.

**Usage:**
```bash
kothari g controller blog
```

**Generated File:** `app/controllers/blog_controller.cr`
```crystal
class BlogController < KothariAPI::Controller
  # GET /blog
  # TODO: implement this action. For example, you might render a list
  # of records or some static JSON.
  def index
    json({ message: "Blog#index" })
  end
end

KothariAPI::ControllerRegistry.register("blog", BlogController)
```

**Generated Route:** `GET /blog` → `blog#index`

**Adding More Actions:**
```crystal
class BlogController < KothariAPI::Controller
  def index
    json_get(Post.all)
  end

  def show
    id = params["id"]?.try &.to_i?
    post = Post.find(id)
    post ? json_get(post) : not_found("Post not found")
  end

  def create
    attrs = permit_body("title", "content")
    post = Post.create(title: attrs["title"].to_s, content: attrs["content"].to_s)
    json_post(post)
  end
end
```

### `kothari g scaffold <name> [field:type ...]`

Generates a complete CRUD scaffold: model, controller, migration, and routes.

**Usage:**
```bash
# Basic scaffold
kothari g scaffold post title:string content:text

# Scaffold with reference type
kothari g scaffold comment post_id:reference content:text

# Scaffold with various types
kothari g scaffold product name:string price:float stock:integer active:bool metadata:json
```

**What it generates:**
1. **Model** - `app/models/post.cr`
2. **Controller** - `app/controllers/posts_controller.cr` (with full CRUD)
3. **Migration** - `db/migrations/<timestamp>_create_posts.sql`
4. **Routes** - Added to `config/routes.cr`

**Generated Routes:**
- `GET /posts` → `posts#index` - List all posts
- `GET /posts/:id` → `posts#show` - Show a post
- `POST /posts` → `posts#create` - Create a post
- `PATCH /posts/:id` → `posts#update` - Update a post
- `DELETE /posts/:id` → `posts#destroy` - Delete a post

**Complete Example:**
```bash
# Generate scaffold
kothari g scaffold post title:string content:text published:bool

# Run migrations
kothari db:migrate

# Start server
kothari server

# Test endpoints
curl http://localhost:3000/posts
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Hello","content":"World","published":true}'
```

**Generated Controller Actions:**
- `index` - Lists all records using `json_get`
- `show` - Shows a single record
- `create` - Creates a new record using `json_post`
- `update` - Updates a record using `json_update`
- `destroy` - Deletes a record using `json_delete`

### `kothari g auth [name]`

Generates a complete authentication system.

**Usage:**
```bash
# Default (creates User model)
kothari g auth

# Custom name
kothari g auth admin
```

**What it generates:**
1. **User Model** - `app/models/user.cr` with `email` and `password_digest`
2. **AuthController** - `app/controllers/auth_controller.cr` with signup/login
3. **Migration** - `db/migrations/<timestamp>_create_users.sql`
4. **Routes** - `POST /signup` and `POST /login`

**Generated Routes:**
- `POST /signup` - Register a new user
- `POST /login` - Authenticate and get JWT token

**Usage Example:**
```bash
# Generate auth
kothari g auth

# Run migrations
kothari db:migrate

# Start server
kothari server

# Signup
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secure123"}'

# Login
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secure123"}'
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "user@example.com",
  "user_id": 1
}
```

**Using the Token:**
```bash
curl http://localhost:3000/protected \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## Database Commands

### `kothari db:migrate`

Runs all pending database migrations in order.

**Usage:**
```bash
kothari db:migrate
```

**What it does:**
- Connects to `db/development.sqlite3`
- Checks which migrations have been run
- Runs pending migrations in timestamp order
- Creates a `schema_migrations` table to track migrations

**Example:**
```bash
# Generate migrations
kothari g migration create_users email:string
kothari g migration create_posts title:string user_id:reference

# Run all migrations
kothari db:migrate
```

**Output:**
```
⚡ Connecting to database...
⚡ Running migrations...
✓ Migrations complete.
```

### `kothari db:reset`

Drops the database, recreates it, and runs all migrations.

**Usage:**
```bash
kothari db:reset
```

**Warning:** This deletes all data in the database!

**What it does:**
1. Deletes `db/development.sqlite3` if it exists
2. Creates a new database
3. Runs all migrations from scratch

**Use Cases:**
- Starting fresh during development
- Testing migrations
- Resetting test data

### `kothari diagram`

Generates a visual database schema diagram showing all tables, fields, and relationships.

**Usage:**
```bash
kothari diagram
```

**What it does:**
- Scans all migrations in `db/migrations/`
- Extracts table structures and field types
- Identifies relationships via `reference` fields
- Generates a Mermaid ER diagram
- Saves to `db/diagram.md`

**Example:**
```bash
# Create models with relationships
kothari g model user email:string
kothari g migration create_users email:string
kothari g model profile user_id:reference name:string
kothari g migration create_profiles user_id:reference name:string

# Run migrations
kothari db:migrate

# Generate diagram
kothari diagram
```

**Generated File:** `db/diagram.md`
```markdown
# Database Schema Diagram

```mermaid
erDiagram
  profiles {
    Int64 id PK
    Int32 user_id FK
    String name
    String created_at
    String updated_at
  }

  users {
    Int64 id PK
    String email
    String created_at
    String updated_at
  }

  profiles ||--o{ users : "user_id"
```
```

**Viewing the Diagram:**
- **GitHub** - Renders Mermaid automatically
- **VS Code** - Install Mermaid extension
- **Online** - Copy to https://mermaid.live

---

## Utility Commands

### `kothari routes`

Lists all registered routes in a formatted table.

**Usage:**
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
GET       /posts                  posts#index
POST      /posts                  posts#create
GET       /posts/:id              posts#show
PATCH     /posts/:id              posts#update
DELETE    /posts/:id              posts#destroy
POST      /signup                 auth#signup
POST      /login                  auth#login

Total: 8 route(s)
```

### `kothari console`

Opens an interactive console (REPL) for exploring your models and running SQL queries.

**Usage:**
```bash
kothari console
```

**Console Commands:**

**Model Commands:**
```ruby
# List all models
models

# Show table structure
Post.show

# List all records
Post.all

# Find by ID
Post.find(1)

# Query with WHERE
Post.where("published = 1")
Post.where("views > 100")
```

**SQL Commands:**
```ruby
# SELECT queries
sql SELECT * FROM posts
sql SELECT * FROM posts WHERE published = 1

# INSERT
sql INSERT INTO posts (title, content) VALUES ('Hello', 'World')

# UPDATE
sql UPDATE posts SET views = views + 1 WHERE id = 1

# DELETE
sql DELETE FROM posts WHERE id = 1

# Schema inspection
sql .schema posts
```

**Example Session:**
```ruby
KothariAPI Console> models
✓ Registered Models:
  • Post
  • User

KothariAPI Console> Post.all
[#<Post:0x... @id=1, @title="Hello", @content="World">]

KothariAPI Console> Post.find(1)
#<Post:0x... @id=1, @title="Hello", @content="World">

KothariAPI Console> sql SELECT COUNT(*) FROM posts
5

KothariAPI Console> exit
```

### `kothari document`

Automatically generates and updates API documentation in README.md.

**Usage:**
```bash
kothari document
```

**What it does:**
- Parses all routes from `config/routes.cr`
- Extracts controller actions
- Generates API documentation with examples
- Updates `README.md` with endpoint documentation

### `kothari benchmark`

Runs performance benchmarks (requires server to be running).

**Usage:**
```bash
# Terminal 1: Start server
kothari server

# Terminal 2: Run benchmark
kothari benchmark
```

### `kothari help`

Displays the help menu with all available commands.

**Usage:**
```bash
kothari help
# OR
kothari
```

---

## Controller Functions

### JSON Response Helpers

#### `json(data)`

Base JSON helper - sets content-type and converts data to JSON.

**Usage:**
```crystal
def index
  json({message: "Hello"})
end
```

**What it does:**
- Sets `Content-Type: application/json`
- Converts data to JSON using `.to_json`
- Writes to response

#### `json_get(data)`

Returns **200 OK** with JSON data. Use for GET requests.

**Usage:**
```crystal
def index
  json_get(Post.all)
end

def show
  post = Post.find(params["id"]?.try &.to_i?)
  post ? json_get(post) : not_found("Post not found")
end
```

**What it does:**
- Sets status to `200 OK`
- Calls `json(data)`

#### `json_post(data)`

Returns **201 Created** with JSON data. Use for POST requests.

**Usage:**
```crystal
def create
  attrs = permit_body("title", "content")
  post = Post.create(
    title: attrs["title"].to_s,
    content: attrs["content"].to_s
  )
  json_post(post)
end
```

**What it does:**
- Sets status to `201 Created`
- Calls `json(data)`

#### `json_update(data)` / `json_patch(data)`

Returns **200 OK** with JSON data. Use for PUT/PATCH requests.

**Usage:**
```crystal
def update
  id = params["id"]?.try &.to_i?
  post = Post.find(id)
  return not_found("Post not found") unless post
  
  attrs = permit_body("title", "content")
  post.update(
    title: attrs["title"]?.to_s,
    content: attrs["content"]?.to_s
  )
  json_update(post)
end
```

**What it does:**
- Sets status to `200 OK`
- Calls `json(data)`

#### `json_delete(data = nil)`

Returns **200 OK** with JSON data, or **204 No Content** if no data provided.

**Usage:**
```crystal
def destroy
  id = params["id"]?.try &.to_i?
  post = Post.find(id)
  return not_found("Post not found") unless post
  
  post.delete
  json_delete({message: "Post deleted successfully"})
  
  # OR for 204 No Content:
  # json_delete
end
```

**What it does:**
- If data provided: `200 OK` + JSON body
- If nil: `204 No Content` + empty body

### Error Response Helpers

#### `bad_request(message, details = nil)`

Returns **400 Bad Request**.

**Usage:**
```crystal
def create
  attrs = permit_body("title", "content")
  return bad_request("Title is required") unless attrs["title"]?
  
  # ... create post
end
```

#### `unauthorized(message = "Unauthorized")`

Returns **401 Unauthorized**.

**Usage:**
```crystal
def show
  return unauthorized("Please log in") unless user_signed_in?
  # ... show resource
end
```

#### `forbidden(message = "Forbidden")`

Returns **403 Forbidden**.

**Usage:**
```crystal
def destroy
  post = Post.find(params["id"]?.try &.to_i?)
  return forbidden("Not your post") unless post.user_id == current_user_id
  # ... delete
end
```

#### `not_found(message = "Not Found")`

Returns **404 Not Found**.

**Usage:**
```crystal
def show
  post = Post.find(params["id"]?.try &.to_i?)
  return not_found("Post not found") unless post
  json_get(post)
end
```

#### `unprocessable_entity(message, errors = nil)`

Returns **422 Unprocessable Entity**.

**Usage:**
```crystal
def create
  attrs = permit_body("title", "content")
  post = Post.create(title: attrs["title"].to_s, content: attrs["content"].to_s)
  json_post(post)
rescue ex
  unprocessable_entity("Validation failed", {
    "title" => [ex.message || "Invalid"]
  })
end
```

#### `internal_server_error(message = "Internal Server Error")`

Returns **500 Internal Server Error**.

**Usage:**
```crystal
def index
  begin
    json_get(Post.all)
  rescue ex
    internal_server_error("Database error: #{ex.message}")
  end
end
```

### Request Data Helpers

#### `params` - Query Parameters

Access query string and path parameters.

**Usage:**
```crystal
# GET /posts?page=1&limit=10
def index
  page = params["page"]?.try &.to_i? || 1
  limit = params["limit"]?.try &.to_i? || 10
  # ... pagination
end

# GET /posts/:id
def show
  id = params["id"]?.try &.to_i?
  post = Post.find(id)
end
```

#### `json_body` - JSON Request Body

Access parsed JSON request body.

**Usage:**
```crystal
def create
  data = json_body
  email = data["email"]?.try &.to_s
  password = data["password"]?.try &.to_s
  # ... create user
end
```

#### `permit_body(*keys)` - Strong Parameters

Only allow specific keys from JSON body (security).

**Usage:**
```crystal
def create
  attrs = permit_body("title", "content", "published")
  # Only title, content, and published are allowed
  # Other keys are ignored
  post = Post.create(
    title: attrs["title"].to_s,
    content: attrs["content"].to_s,
    published: attrs["published"]?.try(&.as_bool) || false
  )
  json_post(post)
end
```

#### `permit_params(*keys)` - Query Parameters

Only allow specific keys from query string.

**Usage:**
```crystal
def index
  allowed = permit_params("page", "limit", "sort")
  page = allowed["page"]?.try &.to_i? || 1
  # ... use allowed params
end
```

### Authentication Helpers

#### `current_user`

Returns the authenticated user (from JWT token).

**Usage:**
```crystal
def show
  user = current_user
  return unauthorized("Please log in") unless user
  json_get(user)
end
```

#### `authenticate_user!`

Stops the request and returns 401 if no user is found. Use in `before_action`.

**Usage:**
```crystal
class PostsController < KothariAPI::Controller
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  
  def create
    # User is guaranteed to be authenticated here
    attrs = permit_body("title", "content")
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      user_id: current_user_id
    )
    json_post(post)
  end
end
```

#### `user_signed_in?`

Returns `true` if user is authenticated.

**Usage:**
```crystal
def index
  if user_signed_in?
    json_get(Post.where("user_id = ?", current_user_id))
  else
    json_get(Post.where("published = 1"))
  end
end
```

#### `current_user_id`

Returns the current user's ID.

**Usage:**
```crystal
def create
  post = Post.create(
    title: attrs["title"].to_s,
    user_id: current_user_id
  )
end
```

### Callbacks

#### `before_action`

Runs a method before the action executes.

**Usage:**
```crystal
class PostsController < KothariAPI::Controller
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :update, :destroy]
  
  private def set_post
    @post = Post.find(params["id"]?.try &.to_i?)
    return not_found("Post not found") unless @post
  end
  
  def show
    json_get(@post)
  end
end
```

**Options:**
- `only: [:action1, :action2]` - Run only for these actions
- `except: [:action1, :action2]` - Run for all except these

#### `after_action`

Runs a method after the action executes.

**Usage:**
```crystal
class PostsController < KothariAPI::Controller
  after_action :log_action
  
  private def log_action
    puts "Action #{params["action"]} completed"
  end
end
```

---

## Model Functions

### Query Methods

#### `Model.all`

Returns all records from the table.

**Usage:**
```crystal
posts = Post.all
json_get(posts)
```

#### `Model.find(id)`

Finds a record by ID. Returns `nil` if not found.

**Usage:**
```crystal
post = Post.find(1)
post ? json_get(post) : not_found("Post not found")
```

#### `Model.find_by(column, value)`

Finds the first record matching the condition.

**Usage:**
```crystal
user = User.find_by("email", "user@example.com")
```

#### `Model.where(condition)`

Returns records matching the WHERE condition.

**Usage:**
```crystal
# Simple condition
published_posts = Post.where("published = 1")

# With parameters (safer)
posts = Post.where("user_id = ? AND published = ?", user_id, true)

# Complex queries
posts = Post.where("views > 100 AND created_at > datetime('now', '-7 days')")
```

### CRUD Methods

#### `Model.create(**fields)`

Creates a new record.

**Usage:**
```crystal
post = Post.create(
  title: "Hello",
  content: "World",
  published: true
)
```

**Returns:** The created model instance

#### `Model#update(**fields)`

Updates an existing record.

**Usage:**
```crystal
post = Post.find(1)
post.update(
  title: "Updated Title",
  content: "Updated Content"
)
```

#### `Model#delete`

Deletes a record.

**Usage:**
```crystal
post = Post.find(1)
post.delete
```

#### `Model.delete(id)`

Deletes a record by ID. Returns `true` if deleted, `false` if not found.

**Usage:**
```crystal
if Post.delete(1)
  json_delete({message: "Deleted"})
else
  not_found("Post not found")
end
```

### Validation

Models include validation support. Add validations in your model:

```crystal
class Post < KothariAPI::Model
  table "posts"
  
  @title : String
  @content : String
  
  property title : String
  property content : String
  
  def initialize(@title : String, @content : String)
    validate!
  end
  
  private def validate!
    errors.clear
    
    if @title.blank?
      errors["title"] << "can't be blank"
    end
    
    if @content.blank?
      errors["content"] << "can't be blank"
    end
    
    raise "Validation failed" unless errors.empty?
  end
end
```

---

## Authentication

### Setting Up Authentication

```bash
# Generate auth system
kothari g auth

# Run migrations
kothari db:migrate
```

### Using Authentication in Controllers

```crystal
class PostsController < KothariAPI::Controller
  # Require authentication for all actions
  before_action :authenticate_user!
  
  # OR require for specific actions
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  
  def index
    # User is authenticated here
    posts = Post.where("user_id = ?", current_user_id)
    json_get(posts)
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
end
```

### Making `current_user` Work

Override the helper methods in your controller:

```crystal
class ApplicationController < KothariAPI::Controller
  private def find_user_by_id(user_id)
    User.find(user_id)
  end
  
  private def find_user_by_email(email)
    User.find_by("email", email)
  end
end
```

Then inherit from `ApplicationController`:

```crystal
class PostsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    user = current_user  # Now works!
    # ...
  end
end
```

---

## Reference Type Feature

### What is Reference Type?

The `reference` type (or `ref`) creates foreign key relationships with automatic indexes.

### Usage

```bash
# Create a model with reference
kothari g model profile user_id:reference name:string bio:text

# Create migration with reference
kothari g migration create_profiles user_id:reference name:string bio:text
```

### What It Does

1. **Creates INTEGER field** - `user_id INTEGER` in database
2. **Adds automatic index** - `CREATE INDEX idx_profiles_user_id ON profiles(user_id)`
3. **Tracks relationship** - For diagram generation

### Example

```bash
# Create User model
kothari g model user email:string
kothari g migration create_users email:string

# Create Profile with reference to User
kothari g model profile user_id:reference name:string bio:text
kothari g migration create_profiles user_id:reference name:string bio:text

# Run migrations
kothari db:migrate

# Generate diagram to see relationship
kothari diagram
```

### In Code

```crystal
# Profile model
class Profile < KothariAPI::Model
  table "profiles"
  
  @user_id : Int32  # Reference becomes Int32
  @name : String
  @bio : String
  
  property user_id : Int32
  property name : String
  property bio : String
end

# Usage
profile = Profile.create(
  user_id: current_user_id,
  name: "John Doe",
  bio: "Developer"
)
```

---

## Database Diagram Feature

### Generating Diagrams

```bash
kothari diagram
```

### What It Shows

- All tables with their fields and types
- Primary keys (PK) and foreign keys (FK)
- Relationships between tables
- Field types (String, Int32, etc.)

### Example Output

After creating models with relationships:

```bash
kothari g model user email:string
kothari g migration create_users email:string
kothari g model post user_id:reference title:string
kothari g migration create_posts user_id:reference title:string
kothari g model comment post_id:reference content:text
kothari g migration create_comments post_id:reference content:text
kothari db:migrate
kothari diagram
```

**Generated `db/diagram.md`:**
```mermaid
erDiagram
  comments {
    Int64 id PK
    Int32 post_id FK
    String content
    String created_at
    String updated_at
  }

  posts {
    Int64 id PK
    Int32 user_id FK
    String title
    String created_at
    String updated_at
  }

  users {
    Int64 id PK
    String email
    String created_at
    String updated_at
  }

  comments ||--o{ posts : "post_id"
  posts ||--o{ users : "user_id"
```

### Viewing Diagrams

- **GitHub** - Automatically renders Mermaid
- **VS Code** - Install "Markdown Preview Mermaid Support" extension
- **Online** - Copy to https://mermaid.live

---

## Advanced Examples

### Complete Blog API

```bash
# 1. Create app
kothari new blog_api
cd blog_api
shards install

# 2. Generate auth
kothari g auth
kothari db:migrate

# 3. Generate Post scaffold
kothari g scaffold post user_id:reference title:string content:text published:bool

# 4. Generate Comment scaffold
kothari g scaffold comment post_id:reference user_id:reference content:text

# 5. Run migrations
kothari db:migrate

# 6. Generate diagram
kothari diagram

# 7. Start server
kothari server
```

### E-commerce API

```bash
kothari new shop_api
cd shop_api
shards install

# Products
kothari g scaffold product name:string price:float stock:integer active:bool metadata:json

# Orders
kothari g scaffold order user_id:reference total:float status:string

# Order Items
kothari g scaffold order_item order_id:reference product_id:reference quantity:integer price:float

kothari db:migrate
kothari diagram
kothari server
```

### Custom Controller Example

```crystal
class ApiController < KothariAPI::Controller
  before_action :authenticate_user!
  
  def stats
    user_count = User.all.size
    post_count = Post.all.size
    
    json_get({
      users: user_count,
      posts: post_count,
      timestamp: Time.utc.to_s
    })
  end
  
  def search
    query = params["q"]?.to_s || ""
    return bad_request("Query required") if query.empty?
    
    posts = Post.where("title LIKE ? OR content LIKE ?", "%#{query}%", "%#{query}%")
    json_get(posts)
  end
end
```

---

## Troubleshooting

### Binary Shows Old Version

**Problem:** `kothari help` shows version 1.0.0 instead of 1.5.0

**Solution:**
```bash
# Rebuild the binary
crystal build src/cli/kothari.cr -o kothari

# If using PATH, update it
cp kothari ~/bin/kothari
# OR
sudo cp kothari /usr/local/bin/kothari
```

### Diagram Command Not Showing

**Problem:** `kothari diagram` command not in help

**Solution:**
1. Make sure you rebuilt the binary after pulling from GitHub
2. Check version: `kothari help | grep Version` (should be 1.5.0)
3. Rebuild: `crystal build src/cli/kothari.cr -o kothari`

### Migration Errors

**Problem:** Migration fails

**Solution:**
- Check SQL syntax in migration file
- Make sure table doesn't already exist
- Use `kothari db:reset` to start fresh (WARNING: deletes data)

### Authentication Not Working

**Problem:** `current_user` returns `nil`

**Solution:**
1. Make sure you override `find_user_by_id` and `find_user_by_email`
2. Check JWT token is being sent: `Authorization: Bearer <token>`
3. Verify token is valid (not expired)

---

## Summary

KothariAPI provides a complete, Rails-inspired framework for building Crystal APIs:

- ✅ **Fast CLI** with beautiful banners
- ✅ **Full CRUD scaffolding** with one command
- ✅ **Database migrations** with automatic timestamps
- ✅ **JWT authentication** built-in
- ✅ **Reference types** for relationships
- ✅ **Database diagrams** for visualization
- ✅ **Interactive console** for data exploration
- ✅ **Type-safe** throughout

**Version 1.5.0** includes:
- Reference type feature
- Database diagram generation
- Enhanced help documentation

For more information, visit: https://github.com/backlinkedclub/kothari_api

