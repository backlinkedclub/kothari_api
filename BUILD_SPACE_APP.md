# Step-by-Step: Building a Space Posts App with Auth & Images

Follow these steps to build an app where users can login, signup, and post about space with images.

## Step 1: Create a New App

```bash
kothari new space_app
cd space_app
```

**Expected output:** You should see the KOTHARI ASCII banner and app creation messages.

---

## Step 2: Install Dependencies

```bash
shards install
```

**Expected output:** Should install `kothari_api` and `jwt` dependencies.

---

## Step 3: Generate Authentication

```bash
kothari g auth
```

**Expected output:**
- ✓ Created auth model User
- ✓ Created AuthController with /signup and /login
- ✓ Added routes POST /signup and POST /login

---

## Step 4: Generate Posts Scaffold with Image Support

```bash
kothari g scaffold post title:string content:text image_url:string user_id:integer
```

**Expected output:**
- ✓ Created Post model
- ✓ Created PostsController
- ✓ Created migration
- ✓ Added routes

---

## Step 5: Run Database Migrations

```bash
kothari db:migrate
```

**Expected output:**
- Applying migrations...
- Migrations complete.
- ✓ Migrations complete.

---

## Step 6: Update PostsController for Image Uploads

Edit `app/controllers/posts_controller.cr` and replace the `create` method with:

```crystal
# POST /posts
# Creates a new Post with optional image upload
def create
  user = get_current_user
  unless user
    unauthorized("Authentication required")
    return
  end

  # Check if this is multipart form data (file upload)
  if uploaded_file = uploaded_file("image")
    # Handle file upload
    image_url = KothariAPI::Storage.save_from_form(uploaded_file)
    
    # Get other fields from form data
    form = form_data
    title = ""
    content = ""
    
    form.try &.each do |part|
      if part.name == "title"
        title = part.body.gets_to_end
      elsif part.name == "content"
        content = part.body.gets_to_end
      end
    end
    
    unless title && content
      bad_request("title and content are required")
      return
    end
    
    record = Post.create(
      title: title,
      content: content,
      image_url: image_url,
      user_id: user.id
    )
  else
    # Handle JSON body (no file upload)
    attrs = post_params
    record = Post.create(
      title: attrs["title"].to_s,
      content: attrs["content"].to_s,
      image_url: attrs["image_url"]?.try &.to_s || "",
      user_id: user.id
    )
  end

  context.response.status = HTTP::Status::CREATED
  json(record)
end

private def get_current_user
  auth_header = context.request.headers["Authorization"]?
  return nil unless auth_header

  token = auth_header.gsub(/^Bearer /, "").strip
  return nil if token.empty?

  begin
    payload = KothariAPI::Auth::JWTAuth.decode(token)
    email = payload["email"]?.try &.to_s
    return nil unless email

    User.find_by("email", email)
  rescue
    nil
  end
end
```

Also update the `index` method to show only user's posts:

```crystal
# GET /posts
def index
  user = get_current_user
  unless user
    unauthorized("Authentication required")
    return
  end

  posts = Post.where("user_id = #{user.id}")
  json(posts)
end
```

And update `post_params`:

```crystal
private def post_params
  permit_body("title", "content", "image_url")
end
```

---

## Step 7: Verify Routes

```bash
kothari routes
```

**Expected output:** Should show:
- GET /
- POST /signup
- POST /login
- GET /posts
- POST /posts
- GET /posts/:id

---

## Step 8: Start the Server

```bash
kothari server -p 3000
```

**Expected output:**
- Running on http://localhost:3000

---

## Step 9: Test Authentication (in another terminal)

### Test Signup:
```bash
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"spacefan@example.com","password":"password123"}'
```

**Expected output:**
```json
{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...","email":"spacefan@example.com"}
```

**Save the token** from the response for the next steps.

### Test Login:
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"spacefan@example.com","password":"password123"}'
```

**Expected output:**
```json
{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...","email":"spacefan@example.com"}
```

---

## Step 10: Create a Post with Image

First, create a test image file:

```bash
# Create a simple test image (or use any PNG/JPG file)
echo "PNG" > space_image.png
```

Then create a post with the image:

```bash
curl -X POST http://localhost:3000/posts \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "title=Amazing Nebula" \
  -F "content=This nebula is absolutely stunning! The colors are incredible." \
  -F "image=@space_image.png"
```

**Replace `YOUR_TOKEN_HERE`** with the token from signup/login.

**Expected output:**
```json
{
  "id": 1,
  "title": "Amazing Nebula",
  "content": "This nebula is absolutely stunning!",
  "image_url": "/uploads/space_image_1234567890.png",
  "user_id": 1,
  "created_at": "...",
  "updated_at": "..."
}
```

---

## Step 11: View Your Posts

```bash
curl -X GET http://localhost:3000/posts \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected output:** Array of your posts with image URLs.

---

## Step 12: View Uploaded Image

The image is accessible at:
```
http://localhost:3000/uploads/FILENAME.png
```

You can open this URL in a browser or use curl:
```bash
curl http://localhost:3000/uploads/FILENAME.png -o downloaded_image.png
```

---

## Complete Example Flow

```bash
# 1. Signup
TOKEN=$(curl -s -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"spacefan@example.com","password":"password123"}' \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# 2. Create post with image
curl -X POST http://localhost:3000/posts \
  -H "Authorization: Bearer $TOKEN" \
  -F "title=Milky Way Galaxy" \
  -F "content=Our beautiful galaxy from Earth!" \
  -F "image=@space_image.png"

# 3. Get all posts
curl -X GET http://localhost:3000/posts \
  -H "Authorization: Bearer $TOKEN"
```

---

## Troubleshooting

### Error: "Authentication required"
**Fix:** Make sure you're including the `Authorization: Bearer TOKEN` header.

### Error: "Database connection failed"
**Fix:** Make sure you're in the app directory and ran `kothari db:migrate`.

### Image not uploading
**Fix:** 
- Make sure you're using `-F` flag (multipart form data)
- Check that the file exists: `ls -la space_image.png`
- Verify the field name is `image` in the curl command

### Image not displaying
**Fix:**
- Check that `public/uploads/` directory exists
- Verify the image URL in the post response
- Make sure the server is running

---

## Next Steps

Once everything works:
1. Users can signup/login
2. Users can create posts about space
3. Users can upload images with posts
4. Images are stored in `public/uploads/`
5. Images are accessible via `/uploads/FILENAME`

**Happy coding! 🚀**

