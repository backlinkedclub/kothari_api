# Step-by-Step: Building an App with Kothari Auth

Follow these steps to build a new app with authentication. If you encounter any errors, paste them here and I'll fix them.

## Step 1: Create a New App

```bash
kothari new my_auth_app
cd my_auth_app
```

**Expected output:** You should see the KOTHARI ASCII banner and app creation messages.

---

## Step 2: Install Dependencies

```bash
shards install
```

**Expected output:** Should install `kothari_api` and `jwt` dependencies.

**If you get an error about `kothari_api` not found:**
- Check that `shard.yml` has the correct dependency
- If you're outside the framework folder, it should use GitHub
- If you're inside the framework folder, it should use `path: ..`

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

## Step 4: Run Database Migrations

```bash
kothari db:migrate
```

**Expected output:**
- Applying migrations...
- Migrations complete.
- ✓ Migrations complete.

---

## Step 5: Verify Routes

```bash
kothari routes
```

**Expected output:** Should show:
- GET /
- POST /signup
- POST /login

---

## Step 6: Start the Server

```bash
kothari server -p 3000
```

**Expected output:**
- Running on http://localhost:3000

**Note:** If port 3000 is in use, it will automatically try the next port.

---

## Step 7: Test Authentication (in another terminal)

### Test Signup:
```bash
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

**Expected output:**
```json
{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...","email":"user@example.com"}
```

### Test Login:
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

**Expected output:**
```json
{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...","email":"user@example.com"}
```

---

## Step 8: (Optional) Add Protected Resources

If you want to add resources that require authentication:

```bash
kothari g scaffold post title:string content:text user_id:integer
kothari db:migrate
```

This creates posts that can be associated with users.

---

## Troubleshooting

### Error: "can't find file 'kothari_api'"
**Fix:** Make sure you ran `shards install` in the app directory.

### Error: "Port already in use"
**Fix:** The server will automatically try the next port. Check the output for the actual port number.

### Error: "Migration failed"
**Fix:** Check that the database file exists and is writable. Try `kothari db:reset` to start fresh.

---

## Next Steps

Once authentication is working:
1. Use the JWT token from `/login` or `/signup`
2. Include it in requests: `Authorization: Bearer <token>`
3. Decode tokens in controllers using `KothariAPI::Auth::JWTAuth.decode(token)`

---

**If you encounter any errors, paste them here and I'll help you fix them!**

