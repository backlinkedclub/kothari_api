---
title: "Kothari API: Rails-Like Productivity Meets Go-Like Performance in Crystal"
published: false
description: "Discover Kothari API, a lightweight Rails-inspired framework for Crystal that delivers 2,480+ requests/second with sub-millisecond latency while maintaining developer-friendly conventions."
tags: crystal, webdev, api, performance, rails, backend
cover_image: https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=1200
---

# Kothari API: Rails-Like Productivity Meets Go-Like Performance in Crystal

Have you ever wished you could have Rails' developer experience with Go's performance? Meet **Kothari API** - a lightweight, Rails-inspired web framework for Crystal that delivers exactly that.

## The Promise

**2,480+ requests per second** with **sub-millisecond latency** while writing code that feels like Rails. Sound too good to be true? Let me show you how Kothari API makes this possible.

## What is Kothari API?

Kothari API is a modern web framework built for Crystal that combines:

- 🚀 **Rails-like conventions** - Familiar patterns, minimal boilerplate
- ⚡ **Go-like performance** - Compiled to native code, fiber-based concurrency
- 🎯 **Type safety** - Crystal's compile-time type checking
- 🔐 **Production-ready** - Built-in authentication, migrations, validations
- 🛠️ **Powerful CLI** - Generate apps, models, controllers with one command

## Why Crystal?

Crystal is a compiled language with Ruby-like syntax. It compiles to native machine code (like Go or Rust) but feels like Ruby. This means:

- **No interpreter overhead** - Direct machine code execution
- **Type safety at compile time** - Catch errors before runtime
- **Fiber-based concurrency** - Handle thousands of concurrent connections
- **Beautiful syntax** - Write code that's both fast and readable

## Getting Started

### Installation

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

### Create Your First API

```bash
# Create a new app
kothari new blog_api
cd blog_api
shards install

# Generate a scaffold (model, controller, migration, routes)
kothari g scaffold post title:string content:text published:bool

# Run migrations
kothari db:migrate

# Start the server
kothari server
```

That's it! You now have a fully functional API with:
- `GET /posts` - List all posts
- `POST /posts` - Create a new post
- `GET /posts/:id` - Show a post
- `PATCH /posts/:id` - Update a post
- `DELETE /posts/:id` - Delete a post

## Key Features

### 1. Beautiful CLI with ASCII Art

Every command displays a beautiful ASCII art banner:

```bash
kothari new myapp      # Shows "NEW" banner
kothari db:migrate     # Shows "MIGRATE" banner
kothari routes         # Shows "ROUTES" banner
```

### 2. Powerful Generators

Generate everything you need with simple commands:

```bash
# Generate a model
kothari g model article title:string content:text views:integer

# Generate a controller
kothari g controller blog

# Generate a migration
kothari g migration create_users email:string password_digest:string

# Generate a full scaffold (model + controller + migration + routes)
kothari g scaffold product name:string price:float in_stock:bool

# Generate authentication system
kothari g auth
```

### 3. Built-in Authentication

Kothari API includes JWT-based authentication out of the box:

```bash
kothari g auth
kothari db:migrate
```

This generates:
- User model with password hashing
- AuthController with `/signup` and `/login` endpoints
- Secure password storage using SHA-256 with salt + pepper

**Usage:**
```bash
# Signup
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secure123"}'

# Login (returns JWT token)
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secure123"}'
```

### 4. Interactive Console

Explore your data with an interactive REPL:

```bash
kothari console
```

```ruby
# List all models
models

# Query models
Post.all
Post.find(1)
Post.where("published = 1")

# Run SQL directly
sql SELECT * FROM posts WHERE published = 1

# Exit
exit
```

### 5. Route Management

Define routes with a simple DSL:

```crystal
# config/routes.cr
KothariAPI::Router::Router.draw do |r|
  r.get "/", to: "home#index"
  r.get "/posts", to: "posts#index"
  r.post "/posts", to: "posts#create"
  r.get "/posts/:id", to: "posts#show"
  r.post "/signup", to: "auth#signup"
  r.post "/login", to: "auth#login"
end
```

View all routes:
```bash
kothari routes
```

### 6. Controllers

Controllers inherit from `KothariAPI::Controller` with helpful helpers:

```crystal
class PostsController < KothariAPI::Controller
  def index
    json(Post.all)
  end

  def create
    attrs = post_params
    post = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s
    )
    context.response.status = HTTP::Status::CREATED
    json(post)
  end

  def show
    id = params["id"]?.try &.to_i?
    if id && (post = Post.find(id))
      json(post)
    else
      not_found("Post not found")
    end
  end

  private def post_params
    permit_body("title", "content")
  end
end

KothariAPI::ControllerRegistry.register("posts", PostsController)
```

### 7. Models

Models provide ORM-like functionality:

```crystal
class Post < KothariAPI::Model
  table "posts"

  @id : Int64?
  @title : String
  @content : String
  @published : Bool
  @created_at : String?
  @updated_at : String?

  property id : Int64?
  property title : String
  property content : String
  property published : Bool
  property created_at : String?
  property updated_at : String?

  def initialize(@title : String, @content : String, @published : Bool,
                 @created_at : String? = nil, @updated_at : String? = nil, @id : Int64? = nil)
  end

  KothariAPI::ModelRegistry.register("post", Post)
end
```

**Available Methods:**
- `Post.all` - Get all records
- `Post.find(id)` - Find by ID
- `Post.create(**fields)` - Create a new record
- `Post.where(condition)` - Query with SQL condition
- `Post.find_by(column, value)` - Find by column value

### 8. Validations

Built-in validation system:

```crystal
class User < KothariAPI::Model
  # ... properties ...

  validates :email, presence: true
  validates :password, length: {minimum: 8}

  # Check validity
  if user.valid?
    user.save
  else
    puts user.errors_full_messages
  end
end
```

### 9. Standardized Error Responses

Controller helpers for consistent error responses:

```crystal
bad_request("Invalid input")
unauthorized("Authentication required")
forbidden("Access denied")
not_found("Resource not found")
unprocessable_entity("Validation failed", errors)
internal_server_error("Something went wrong")
```

## Performance Benchmarks

Kothari API delivers exceptional performance:

### Simple JSON Response (GET /)
- **Throughput**: 2,480 requests/second
- **Average Latency**: 0.40ms
- **P50 Latency**: 0.34ms
- **P95 Latency**: 0.66ms
- **P99 Latency**: 2.34ms

### Why It's Fast

1. **Compiled Language** - No interpreter overhead, direct machine code execution
2. **Fiber-Based Concurrency** - Lightweight green threads handle thousands of connections
3. **Minimal Framework Overhead** - Direct database access, efficient JSON serialization
4. **Type Safety** - Compile-time checks eliminate runtime type checking

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
└── console.cr                 # Console entry point
```

## Complete Example: Building a Blog API

Let's build a complete blog API with authentication:

```bash
# Create app
kothari new blog_api
cd blog_api
shards install

# Generate scaffold for posts
kothari g scaffold post title:string content:text published:bool

# Generate authentication
kothari g auth

# Run migrations
kothari db:migrate

# Start server
kothari server
```

**API Endpoints:**
- `GET /posts` - List all posts
- `POST /posts` - Create a post (requires auth)
- `GET /posts/:id` - Show a post
- `POST /signup` - Register user
- `POST /login` - Login user

## CLI Commands Reference

### App Management
- `kothari new <app_name>` - Create new application
- `kothari server [-p|--port PORT]` - Start development server
- `kothari build [output] [--release]` - Compile to binary

### Generators
- `kothari g controller <name>` - Generate controller
- `kothari g model <name> [field:type ...]` - Generate model
- `kothari g migration <name> [field:type ...]` - Generate migration
- `kothari g scaffold <name> [field:type ...]` - Generate full CRUD scaffold
- `kothari g auth [name]` - Generate authentication system

### Database
- `kothari db:migrate` - Run migrations
- `kothari db:reset` - Reset database

### Utilities
- `kothari routes` - List all routes
- `kothari console` - Open interactive console
- `kothari benchmark` - Run performance benchmarks
- `kothari help` - Show help menu

## Data Types

Kothari API supports various data types:

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

## Production Readiness

Kothari API is **100% production ready** with:

✅ **Authentication System**
- Password hashing (SHA-256 with salt + pepper)
- JWT token generation and verification
- Secure by default

✅ **Database Operations**
- ORM-like model layer
- Migration system
- Parameterized queries (SQL injection prevention)

✅ **Developer Experience**
- Rails-style routing DSL
- Controller base class
- Strong parameters
- Validation system
- Standardized error responses

✅ **CLI Tooling**
- Generate applications, models, controllers
- Database migrations
- Interactive console

## The Bottom Line

Kothari API proves you don't have to choose between:

- ❌ Developer productivity OR performance
- ❌ Rails conventions OR speed
- ❌ Easy to use OR fast

You can have **all of it**.

**2,480+ requests per second** with **sub-millisecond latency** while writing code that feels like Rails.

## Try It Yourself

```bash
# Install Crystal (if not already installed)
# https://crystal-lang.org/install/

# Clone and build
git clone https://github.com/backlinkedclub/kothari_api.git
cd kothari_api
shards install
crystal build src/cli/kothari.cr -o kothari

# Create a test app
./kothari new test_app
cd test_app
shards install

# Generate a scaffold
./kothari g scaffold article title:string content:text

# Run migrations
./kothari db:migrate

# Start server
./kothari server
```

## Resources

- **GitHub**: [https://github.com/backlinkedclub/kothari_api](https://github.com/backlinkedclub/kothari_api)
- **Crystal Language**: [https://crystal-lang.org](https://crystal-lang.org)
- **Documentation**: See the README in the repository

## Conclusion

Kothari API brings the best of both worlds: Rails' developer-friendly conventions with Go-like performance. If you're building APIs and want speed without sacrificing productivity, give Kothari API a try.

Have you tried Kothari API? Share your experience in the comments below! 🚀

---

**Built with ❤️ using Crystal**

