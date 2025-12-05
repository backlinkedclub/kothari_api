# cURL Examples for KothariAPI with JWT Authentication

Quick reference for testing your API with cURL and JWT tokens.

## Quick Start

### 1. Sign Up (Get JWT Token)

```bash
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

### 2. Login (Get JWT Token)

```bash
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

### 3. Create a Post (Protected - Requires JWT)

```bash
# Save token to variable
TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

# Create post with authentication
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "My First Post",
    "content": "This is the content of my post"
  }'
```

**Response (201 Created):**
```json
{
  "id": 1,
  "title": "My First Post",
  "content": "This is the content of my post",
  "user_id": 1,
  "created_at": "2024-01-01 12:00:00",
  "updated_at": "2024-01-01 12:00:00"
}
```

### 4. Get All Posts (Public - No Auth Needed)

```bash
curl -X GET http://localhost:3000/posts
```

### 5. Get Single Post (Public - No Auth Needed)

```bash
curl -X GET http://localhost:3000/posts/1
```

### 6. Update Post (Protected - Requires JWT)

```bash
curl -X PATCH http://localhost:3000/posts/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Updated Title",
    "content": "Updated content"
  }'
```

### 7. Delete Post (Protected - Requires JWT)

```bash
curl -X DELETE http://localhost:3000/posts/1 \
  -H "Authorization: Bearer $TOKEN"
```

## Complete Workflow Example

```bash
# 1. Sign up
RESPONSE=$(curl -s -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}')

# 2. Extract token (using jq if available)
TOKEN=$(echo $RESPONSE | jq -r '.token')

# Or manually copy the token from the response
# TOKEN="your_token_here"

# 3. Create a post
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "My Post",
    "content": "Post content here"
  }'

# 4. List all posts
curl -X GET http://localhost:3000/posts

# 5. Update the post
curl -X PATCH http://localhost:3000/posts/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Updated Post Title"
  }'

# 6. Delete the post
curl -X DELETE http://localhost:3000/posts/1 \
  -H "Authorization: Bearer $TOKEN"
```

## Testing Authentication

### Test Without Token (Should Fail)

```bash
# This should return 401 Unauthorized
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My Post",
    "content": "Post content"
  }'
```

**Expected Response (401):**
```json
{
  "error": "Authentication required"
}
```

### Test With Invalid Token (Should Fail)

```bash
# This should return 401 Unauthorized
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token_here" \
  -d '{
    "title": "My Post",
    "content": "Post content"
  }'
```

## How current_user.id Works

In your controller, after `before_action :authenticate_user!` runs:

```crystal
def create
  # current_user is available (User object)
  # current_user.id returns the user's ID (Int64?)
  # current_user_id is a helper that returns current_user.try &.id
  
  post = Post.create(
    title: attrs["title"].to_s,
    content: attrs["content"].to_s,
    user_id: current_user_id  # ✅ Recommended - handles nil safely
    # OR
    user_id: current_user.not_nil!.id  # ✅ Works if user exists (guaranteed by authenticate_user!)
  )
end
```

**Key Points:**
- `current_user` returns the User object (or nil)
- `current_user.id` returns the user's ID (Int64?)
- `current_user_id` is a helper that safely returns `current_user.try &.id`
- After `before_action :authenticate_user!`, `current_user` is guaranteed to exist
- The JWT token contains `user_id` and `email` which are used to find the user

## Troubleshooting

### Error: "Authentication required"
- Make sure you're including the `Authorization: Bearer <token>` header
- Check that the token is valid (not expired)
- Verify the token was obtained from `/signup` or `/login`

### Error: "Invalid token"
- Token may be expired (default: 1 hour)
- Token may be malformed
- Try getting a new token from `/login`

### Error: "User not found"
- Make sure you've overridden `find_user_by_id` and `find_user_by_email` in your controller
- Check that the User model exists and has `find` and `find_by` methods

