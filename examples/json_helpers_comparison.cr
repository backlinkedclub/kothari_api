# JSON Helpers Comparison Example
# This file demonstrates the difference between manual JSON writing and using helpers

require "../src/kothari_api"

# This is a demonstration controller showing both approaches side-by-side
class ComparisonController < KothariAPI::Controller
  # Example data structure
  class Post
    include JSON::Serializable
    
    def initialize(@id : Int32, @title : String, @content : String)
    end
  end

  # ============================================
  # APPROACH 1: Manual JSON Writing (Verbose)
  # ============================================
  
  def show_manual
    post = Post.new(1, "Hello", "World")
    
    # Manual approach: You must do everything yourself
    context.response.status = HTTP::Status::OK
    context.response.content_type = "application/json"
    context.response.print post.to_json
    
    # Issues:
    # - 3 lines of boilerplate every time
    # - Easy to forget content-type
    # - Easy to use wrong status code
    # - Repetitive across all actions
  end
  
  def create_manual
    post = Post.new(1, "New Post", "Content")
    
    # Manual: Must remember 201 for POST
    context.response.status = HTTP::Status::CREATED
    context.response.content_type = "application/json"
    context.response.print post.to_json
    
    # Same 3 lines repeated again!
  end
  
  def update_manual
    post = Post.new(1, "Updated", "Content")
    
    # Manual: Must remember 200 for PUT/PATCH
    context.response.status = HTTP::Status::OK
    context.response.content_type = "application/json"
    context.response.print post.to_json
    
    # Same 3 lines repeated AGAIN!
  end
  
  def delete_manual
    # Manual: Must handle two cases
    if true  # Condition: send message or not
      context.response.status = HTTP::Status::OK
      context.response.content_type = "application/json"
      context.response.print({message: "Deleted"}.to_json)
    else
      context.response.status = HTTP::Status::NO_CONTENT
      context.response.print ""
    end
    
    # Even more complex with conditionals!
  end

  # ============================================
  # APPROACH 2: Using JSON Helpers (Clean)
  # ============================================
  
  def show_helper
    post = Post.new(1, "Hello", "World")
    
    # Helper approach: One line, everything handled automatically
    json_get(post)
    
    # Behind the scenes, this does:
    #   1. Sets status to 200 OK
    #   2. Sets content-type to application/json
    #   3. Converts post.to_json
    #   4. Prints to response
  end
  
  def create_helper
    post = Post.new(1, "New Post", "Content")
    
    # Helper: One line, correct status code (201) automatically
    json_post(post)
    
    # Behind the scenes:
    #   1. Sets status to 201 Created
    #   2. Sets content-type to application/json
    #   3. Converts post.to_json
    #   4. Prints to response
  end
  
  def update_helper
    post = Post.new(1, "Updated", "Content")
    
    # Helper: One line, correct status code (200) automatically
    json_update(post)
    
    # Behind the scenes:
    #   1. Sets status to 200 OK
    #   2. Sets content-type to application/json
    #   3. Converts post.to_json
    #   4. Prints to response
  end
  
  def delete_helper
    # Helper: Handles both cases elegantly
    json_delete({message: "Post deleted successfully"})  # Returns 200 OK
    
    # OR for 204 No Content:
    # json_delete  # No data = 204
    
    # Behind the scenes:
    #   - If data provided: 200 OK + JSON body
    #   - If nil: 204 No Content + empty body
  end

  # ============================================
  # SIDE-BY-SIDE COMPARISON
  # ============================================
  
  # Complete action: Manual
  def index_manual
    posts = [Post.new(1, "Post 1", "Content 1"), Post.new(2, "Post 2", "Content 2")]
    
    context.response.status = HTTP::Status::OK
    context.response.content_type = "application/json"
    context.response.print posts.to_json
  end
  
  # Complete action: Helper
  def index_helper
    posts = [Post.new(1, "Post 1", "Content 1"), Post.new(2, "Post 2", "Content 2")]
    
    json_get(posts)  # Same result, 1 line instead of 3!
  end
  
  # Error handling: Manual
  def show_with_error_manual
    post = Post.find_by_id(params["id"]?.try &.to_i?)
    
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
  
  # Error handling: Helper
  def show_with_error_helper
    post = Post.find_by_id(params["id"]?.try &.to_i?)
    
    if post
      json_get(post)  # One line
    else
      not_found("Post not found")  # Also a helper!
    end
  end
end

# ============================================
# WHAT HAPPENS BEHIND THE SCENES
# ============================================

# When you call json_get(data), here's the execution flow:
#
# 1. json_get(data) is called
#    ↓
# 2. Sets: context.response.status = HTTP::Status::OK
#    ↓
# 3. Calls: json(data)
#    ↓
# 4. Sets: context.response.content_type = "application/json"
#    ↓
# 5. Calls: data.to_json (converts your object to JSON string)
#    ↓
# 6. Calls: context.response.print(json_string)
#    ↓
# 7. Response is sent to client
#
# All of this happens automatically in one method call!

# ============================================
# LINE COUNT COMPARISON
# ============================================

# Manual approach for 5 REST actions:
# - index: 3 lines
# - show: 6 lines (with error handling)
# - create: 3 lines
# - update: 3 lines
# - destroy: 5 lines (with conditional)
# Total: ~20 lines of boilerplate

# Helper approach for 5 REST actions:
# - index: 1 line
# - show: 2 lines (with error helper)
# - create: 1 line
# - update: 1 line
# - destroy: 1 line
# Total: ~6 lines

# Result: 70% less code, more readable, fewer bugs!

