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

#### `kothari console`

Opens an interactive console for exploring your models and running SQL queries.

```bash
kothari console
```

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

Controllers inherit from `KothariAPI::Controller`:

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

  private def post_params
    JSON.parse(context.request.body.not_nil!.gets_to_end).as_h
  end
end

KothariAPI::ControllerRegistry.register("posts", PostsController)
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
- `Post.where(condition)` - Query with SQL condition

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

## ASCII Art Banners

Every command displays a beautiful ASCII art banner with the command name:

```bash
kothari new myapp      # Shows "NEW" banner
kothari db:migrate     # Shows "MIGRATE" banner
kothari routes         # Shows "ROUTES" banner
kothari help           # Shows "HELP" banner
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
