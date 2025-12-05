# JSON Helpers Demo: Behind the Scenes

This document demonstrates the difference between writing JSON responses manually versus using the JSON helpers provided by KothariAPI.

## Visual Execution Flow

When you call a JSON helper, here's exactly what happens:

```
┌─────────────────────────────────────────────────────────────┐
│  Your Code: json_get(post)                                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 1: json_get(data) is called                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ def json_get(data)                                   │   │
│  │   context.response.status = HTTP::Status::OK  ←──────┼───┼─ Sets 200 OK
│  │   json(data)                                         │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: json(data) is called                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ def json(data)                                       │   │
│  │   context.response.content_type = "application/json"│←──┼─ Sets Content-Type
│  │   context.response.print data.to_json  ←────────────┼───┼─ Converts & prints
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: data.to_json converts your object                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ post.to_json                                         │   │
│  │   → '{"id":1,"title":"Hello","content":"World"}'    │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: Response is sent to client                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ HTTP/1.1 200 OK                                      │   │
│  │ Content-Type: application/json                       │   │
│  │                                                      │   │
│  │ {"id":1,"title":"Hello","content":"World"}          │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Manual approach requires you to do ALL of these steps yourself:**
```crystal
# You must manually do what the helper does automatically:
context.response.status = HTTP::Status::OK              # Step 1
context.response.content_type = "application/json"      # Step 2
context.response.print post.to_json                     # Steps 3 & 4
```

## Quick Reference: Manual vs Helper

| What You Want | Manual (3-4 lines) | Helper (1 line) |
|---------------|---------------------|-----------------|
| GET response (200 OK) | `context.response.status = HTTP::Status::OK`<br>`context.response.content_type = "application/json"`<br>`context.response.print data.to_json` | `json_get(data)` |
| POST response (201 Created) | `context.response.status = HTTP::Status::CREATED`<br>`context.response.content_type = "application/json"`<br>`context.response.print data.to_json` | `json_post(data)` |
| PUT/PATCH response (200 OK) | `context.response.status = HTTP::Status::OK`<br>`context.response.content_type = "application/json"`<br>`context.response.print data.to_json` | `json_update(data)` |
| DELETE with message (200 OK) | `context.response.status = HTTP::Status::OK`<br>`context.response.content_type = "application/json"`<br>`context.response.print data.to_json` | `json_delete(data)` |
| DELETE no message (204 No Content) | `context.response.status = HTTP::Status::NO_CONTENT`<br>`context.response.print ""` | `json_delete` |

**The helpers save you 2-3 lines of boilerplate code per response!**

## The Core Helper: `json(data)`

The base `json` helper does three things:
1. Sets the `Content-Type` header to `application/json`
2. Converts your data to JSON using `.to_json`
3. Writes it to the response

**Implementation:**
```crystal
def json(data)
  context.response.content_type = "application/json"
  context.response.print data.to_json
end
```

## Comparison: Manual vs Helper

### Example 1: Simple GET Response

#### ❌ Manual Way (Without Helper)
```crystal
def show
  post = Post.find(params["id"]?.try &.to_i?)
  if post
    # Manual: You must do everything yourself
    context.response.status = HTTP::Status::OK
    context.response.content_type = "application/json"
    context.response.print post.to_json
  else
    context.response.status = HTTP::Status::NOT_FOUND
    context.response.content_type = "application/json"
    context.response.print({error: "Post not found"}.to_json)
  end
end
```

**What happens:**
- Line 4: Set status code manually
- Line 5: Set content type manually
- Line 6: Convert to JSON and print manually
- Lines 8-10: Repeat all three steps for error case

#### ✅ Helper Way (With `json_get`)
```crystal
def show
  post = Post.find(params["id"]?.try &.to_i?)
  if post
    json_get(post)  # One line!
  else
    not_found("Post not found")
  end
end
```

**What happens behind the scenes:**
```crystal
# When you call json_get(post), this executes:
def json_get(data)
  context.response.status = HTTP::Status::OK      # ← Sets status automatically
  json(data)                                      # ← Calls base json helper
end

# Which then calls:
def json(data)
  context.response.content_type = "application/json"  # ← Sets content type
  context.response.print data.to_json                  # ← Converts & prints
end
```

**Benefits:**
- ✅ One line instead of three
- ✅ Consistent status codes (200 OK for GET)
- ✅ No risk of forgetting content-type
- ✅ Cleaner, more readable code

---

### Example 2: Creating a Resource (POST)

#### ❌ Manual Way
```crystal
def create
  attrs = permit_body("title", "content")
  post = Post.create(
    title: attrs["title"].to_s,
    content: attrs["content"].to_s
  )
  
  # Manual: Set status, content type, and convert
  context.response.status = HTTP::Status::CREATED  # ← Must remember 201 for POST
  context.response.content_type = "application/json"
  context.response.print post.to_json
end
```

**Issues:**
- Easy to forget the correct status code (201 vs 200)
- Three lines of boilerplate every time
- Easy to miss setting content-type

#### ✅ Helper Way
```crystal
def create
  attrs = permit_body("title", "content")
  post = Post.create(
    title: attrs["title"].to_s,
    content: attrs["content"].to_s
  )
  
  json_post(post)  # One line, correct status code!
end
```

**What happens behind the scenes:**
```crystal
# When you call json_post(post):
def json_post(data)
  context.response.status = HTTP::Status::CREATED  # ← Automatically 201
  json(data)                                       # ← Handles content-type & JSON
end

# Which calls:
def json(data)
  context.response.content_type = "application/json"
  context.response.print data.to_json
end
```

**Benefits:**
- ✅ Correct status code (201 Created) automatically
- ✅ One line instead of three
- ✅ Follows REST conventions

---

### Example 3: Updating a Resource (PUT/PATCH)

#### ❌ Manual Way
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
  
  # Manual: Set status, content type, convert
  context.response.status = HTTP::Status::OK
  context.response.content_type = "application/json"
  context.response.print post.to_json
end
```

#### ✅ Helper Way
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
  
  json_update(post)  # One line!
end
```

**Behind the scenes:**
```crystal
def json_update(data)
  context.response.status = HTTP::Status::OK  # ← 200 OK for updates
  json(data)
end
```

---

### Example 4: Deleting a Resource

#### ❌ Manual Way
```crystal
def destroy
  id = params["id"]?.try &.to_i?
  post = Post.find(id)
  return not_found("Post not found") unless post
  
  post.delete
  
  # Manual: Handle two cases (with/without data)
  if send_message
    context.response.status = HTTP::Status::OK
    context.response.content_type = "application/json"
    context.response.print({message: "Deleted"}.to_json)
  else
    context.response.status = HTTP::Status::NO_CONTENT
    context.response.print ""
  end
end
```

#### ✅ Helper Way
```crystal
def destroy
  id = params["id"]?.try &.to_i?
  post = Post.find(id)
  return not_found("Post not found") unless post
  
  post.delete
  
  json_delete({message: "Post deleted successfully"})  # Returns 200 OK
  # OR
  # json_delete  # Returns 204 No Content (no body)
end
```

**Behind the scenes:**
```crystal
def json_delete(data = nil)
  if data.nil?
    context.response.status = HTTP::Status::NO_CONTENT  # ← 204 if no data
    context.response.print ""
  else
    context.response.status = HTTP::Status::OK          # ← 200 if data provided
    json(data)                                          # ← Handles JSON conversion
  end
end
```

**Benefits:**
- ✅ Handles both cases (204 No Content vs 200 OK)
- ✅ Cleaner conditional logic
- ✅ Follows REST best practices

---

## Summary: What Helpers Do For You

| Task | Manual | Helper |
|------|--------|--------|
| Set Content-Type | `context.response.content_type = "application/json"` | ✅ Automatic |
| Convert to JSON | `data.to_json` | ✅ Automatic |
| Set Status Code | `context.response.status = HTTP::Status::XXX` | ✅ Automatic (correct for each method) |
| Write to Response | `context.response.print ...` | ✅ Automatic |
| **Total Lines** | **3-4 lines** | **1 line** |

## All Available Helpers

```crystal
# Base helper (sets content-type, converts to JSON)
json(data)                    # Generic JSON response

# HTTP method-specific helpers (set status + call json)
json_get(data)                # 200 OK
json_post(data)               # 201 Created
json_update(data)             # 200 OK
json_patch(data)              # 200 OK (alias for json_update)
json_delete(data = nil)       # 200 OK (with data) or 204 No Content (no data)
```

## Real-World Example: Complete Controller

### ❌ Without Helpers (Verbose)
```crystal
class PostsController < KothariAPI::Controller
  def index
    context.response.status = HTTP::Status::OK
    context.response.content_type = "application/json"
    context.response.print Post.all.to_json
  end
  
  def show
    post = Post.find(params["id"]?.try &.to_i?)
    if post
      context.response.status = HTTP::Status::OK
      context.response.content_type = "application/json"
      context.response.print post.to_json
    else
      context.response.status = HTTP::Status::NOT_FOUND
      context.response.content_type = "application/json"
      context.response.print({error: "Not found"}.to_json)
    end
  end
  
  def create
    attrs = permit_body("title", "content")
    post = Post.create(title: attrs["title"].to_s, content: attrs["content"].to_s)
    context.response.status = HTTP::Status::CREATED
    context.response.content_type = "application/json"
    context.response.print post.to_json
  end
  
  def update
    post = Post.find(params["id"]?.try &.to_i?)
    return unless post
    attrs = permit_body("title", "content")
    post.update(title: attrs["title"]?.to_s, content: attrs["content"]?.to_s)
    context.response.status = HTTP::Status::OK
    context.response.content_type = "application/json"
    context.response.print post.to_json
  end
  
  def destroy
    post = Post.find(params["id"]?.try &.to_i?)
    return unless post
    post.delete
    context.response.status = HTTP::Status::OK
    context.response.content_type = "application/json"
    context.response.print({message: "Deleted"}.to_json)
  end
end
```

### ✅ With Helpers (Clean)
```crystal
class PostsController < KothariAPI::Controller
  def index
    json_get(Post.all)
  end
  
  def show
    post = Post.find(params["id"]?.try &.to_i?)
    post ? json_get(post) : not_found("Post not found")
  end
  
  def create
    attrs = permit_body("title", "content")
    post = Post.create(title: attrs["title"].to_s, content: attrs["content"].to_s)
    json_post(post)
  end
  
  def update
    post = Post.find(params["id"]?.try &.to_i?)
    return not_found("Post not found") unless post
    attrs = permit_body("title", "content")
    post.update(title: attrs["title"]?.to_s, content: attrs["content"]?.to_s)
    json_update(post)
  end
  
  def destroy
    post = Post.find(params["id"]?.try &.to_i?)
    return not_found("Post not found") unless post
    post.delete
    json_delete({message: "Post deleted successfully"})
  end
end
```

**Result:** 
- **Without helpers:** ~40 lines
- **With helpers:** ~20 lines
- **50% less code, more readable, fewer bugs!**

---

## Key Takeaways

1. **Helpers eliminate boilerplate** - No need to manually set content-type, status codes, or call `to_json`
2. **Consistent status codes** - Helpers use the correct HTTP status codes for each method
3. **Less error-prone** - Can't forget to set content-type or use wrong status code
4. **More readable** - Intent is clear: `json_post(post)` vs 3 lines of setup code
5. **Follows conventions** - Automatically follows REST API best practices

The helpers are thin wrappers that handle the repetitive HTTP response setup, letting you focus on your business logic instead of HTTP details.

