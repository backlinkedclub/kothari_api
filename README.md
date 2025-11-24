## KothariAPI – Lightweight Crystal Web Framework

KothariAPI is a small, Rails‑inspired web framework for Crystal. It provides:

- **CLI**: `kothari` for generating apps and controllers.
- **Router DSL**: `KothariAPI::Router::Router.draw do |r| ... end`.
- **Base controller**: `KothariAPI::Controller` with JSON helpers.

This document explains what is currently implemented and what was fixed in this iteration.

---

## Project Layout

- **Framework shard** (this repo):
  - `src/kothari_api.cr` – main entry for the shard, requires all framework pieces.
  - `src/kothari_api/controller.cr` – base controller class.
  - `src/kothari_api/router/route.cr` – `Route` value object (method, path, controller, action).
  - `src/kothari_api/router/router.cr` – `Router` class and routing DSL.
  - `src/cli/kothari.cr` – CLI entry point (`kothari`).

- **Generated app** (e.g. `/var/crystal_programs/demoapp`):
  - `app/controllers/` – application controllers.
  - `app/controllers.cr` – requires all controllers.
  - `config/routes.cr` – application routes.
  - `src/server.cr` – HTTP server that uses the router and controllers.

---

## Router: Design and Fix

### Route Representation

`KothariAPI::Router::Route` holds the HTTP method, path, controller, and action:

- `method` – HTTP verb (e.g. `"GET"`).
- `path` – request path pattern (e.g. `"/"` or `"/users"`).
- `controller` – string name from the `to:` DSL (e.g. `"home"`).
- `action` – action name (e.g. `"index"`).

It is created via `Route.new(method, path, to)`, where `to` is of the form `"controller#action"`.

### Router DSL

The router lives in `src/kothari_api/router/router.cr` as `KothariAPI::Router::Router` and supports:

- **Registering routes**:
  - `get(path : String, to : String)`
  - `post(path : String, to : String)`
- **Looking up a route**:
  - `match(method : String, path : String)` – returns a `Route?`.
- **DSL**:
  - `draw` yields the router itself so you can define routes in a block.

The DSL is used like this:

```crystal
KothariAPI::Router::Router.draw do |r|
  r.get "/", to: "home#index"
end
```

### Critical Fix: `draw` Block Parameter Error

Originally, `draw` was implemented as:

```crystal
def self.draw(&block)
  block.call(self)
end
```

Calling it with `do |r|` caused:

> Error: wrong number of block parameters (given 1, expected 0)

Crystal’s compiler did not know that the block accepted one argument when written this way.

**Solution**: switch to `yield self`, letting Crystal infer the block arity correctly:

```crystal
def self.draw
  yield self
end
```

Now `draw do |r|` works exactly as intended, and there is only one router implementation: `src/kothari_api/router/router.cr`.

---

## Base Controller

`src/kothari_api/controller.cr` defines `KothariAPI::Controller`:

- **Holds the HTTP context**:
  - `getter context : HTTP::Server::Context`
  - Initialized with `def initialize(@context)`.
- **JSON helper**:
  - `def json(data)` sets `Content-Type` to `application/json` and prints `data.to_json`.

All application controllers inherit from this base class, e.g.:

```crystal
class HomeController < KothariAPI::Controller
  def index
    json({ message: "Welcome to KothariAPI" })
  end
end
```

---

## CLI (`kothari`)

The CLI entry is `src/cli/kothari.cr` and supports:

- **`kothari new <app_name>`** – generate a new app.
- **`kothari server`** – run `crystal run src/server.cr` in the current app.
- **`kothari g controller <name>`** – generate a new controller and route.

### What `kothari new` Generates

For `kothari new demoapp`, the CLI:

- Creates directories:
  - `demoapp/app/controllers`
  - `demoapp/config`
  - `demoapp/src`
- Writes `demoapp/shard.yml`:
  - Adds a **path dependency** on this framework:

    ```yaml
    dependencies:
      kothari_api:
        path: /var/crystal_programs/kothari_api
    ```

  - Sets the main target to `src/server.cr`.
- Generates `config/routes.cr`:

  ```crystal
  KothariAPI::Router::Router.draw do |r|
    r.get "/", to: "home#index"
  end
  ```

- Generates `app/controllers/home_controller.cr` with `HomeController#index`.
- Generates `app/controllers.cr` that requires `kothari_api` and `home_controller`.

### Generated `src/server.cr`

The CLI now generates a **simple, working** HTTP server:

- Requires controllers, the framework, routes, and `http/server`.
- Creates `HTTP::Server` and uses the router to match incoming requests.
- For now, it dispatches directly to `HomeController#index` when a route is found.
- Returns 404 with a JSON error when no route is found.

This design:

- Avoids unsupported Ruby APIs (`Object.const_get`, `send`).
- Plays nicely with Crystal’s static type system.
- Ensures that `kothari new` + `kothari server` produce a **compilable, runnable** app.

---

## `kothari g controller`

The generator:

- Creates `app/controllers/<name>_controller.cr` with a basic `index` action.
- Appends a `require` to `app/controllers.cr`.
- Inserts a new `r.get "/<name>", to: "<name>#index"` route into `config/routes.cr` before the final `end`.

This keeps all routes inside the single `Router.draw` block and lets you grow your app incrementally.

---

## How to Build and Install the CLI

From this framework repo (`/var/crystal_programs/kothari_api`):

```bash
crystal build src/cli/kothari.cr -o kothari
sudo mv kothari /usr/local/bin/kothari   # or /usr/bin/kothari
```

Now you can use `kothari` globally:

```bash
kothari new myapp
cd myapp
shards install
kothari server
```

Then open `http://localhost:3000` in your browser.

---

## Summary of Key Fixes and Behaviors

- **Router DSL**:
  - `Router.draw` now uses `yield self`, fixing the block parameter error.
  - There is a single, authoritative router implementation in `src/kothari_api/router/router.cr`.
- **CLI server template**:
  - Removed Ruby-style `Object.const_get` and `send`.
  - Generates a minimal, type-safe demo server using `HomeController#index`.
  - Uses `HTTP::Status::NOT_FOUND` instead of a bare integer for 404.
- **End‑to‑end flow now works**:
  - `kothari new demoapp`
  - `cd demoapp && shards install`
  - `kothari server`
  - Visit `http://localhost:3000` to see the JSON welcome message.

From here you can iterate on more advanced, compile‑time‑safe controller dispatch (e.g., macros or registries), knowing the router and CLI scaffolding are in a correct, working state.


