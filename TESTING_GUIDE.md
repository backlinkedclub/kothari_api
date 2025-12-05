# Kothari API Framework - Complete Testing Guide

## Quick Start Testing

### Step 1: Build the Framework CLI
```bash
cd /var/crystal_programs/kothari_api
crystal build src/cli/kothari.cr -o kothari
```

### Step 2: Create a Test App
```bash
./kothari new my_test_app
cd my_test_app
shards install
```

### Step 3: Start the Server
```bash
../kothari server
```

### Step 4: Test Basic Functionality
```bash
# In another terminal
curl http://localhost:3000/
# Should return: {"message":"Welcome to KothariAPI"}
```

## Test App Creation (Using Only Kothari Commands)

Here's a complete walkthrough using only kothari framework commands:

### 1. Create New App
```bash
kothari new blog_api
cd blog_api
shards install
```

### 2. Generate Scaffold
```bash
kothari g scaffold post title:string content:text published:bool
```

### 3. Run Migrations
```bash
kothari db:migrate
```

### 4. Generate Authentication
```bash
kothari g auth
kothari db:migrate
```

### 5. Start Server
```bash
kothari server
```

### 6. Test API Endpoints
```bash
# Create a post
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Post","content":"This is a test","published":true}'

# List posts
curl http://localhost:3000/posts

# Signup user
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

## Error Documentation

All errors found during testing are documented in:
- **TEST_ERRORS_README.md** - Complete error log and status

## ChatGPT Testing

Use the prompts in **CHATGPT_TEST_PROMPTS.md** to systematically test every component of the framework.

## Test Checklist

### Framework Core
- [x] CLI builds successfully
- [x] App generation works
- [x] Shard dependencies install
- [ ] Server starts without errors
- [ ] Routes work correctly
- [ ] Controllers respond
- [ ] Models work
- [ ] Database migrations work

### Generators
- [ ] Controller generator
- [ ] Model generator
- [ ] Migration generator
- [ ] Scaffold generator
- [ ] Auth generator

### Commands
- [ ] `kothari server`
- [ ] `kothari build`
- [ ] `kothari routes`
- [ ] `kothari console`
- [ ] `kothari document`
- [ ] `kothari db:migrate`
- [ ] `kothari db:reset`
- [ ] `kothari benchmark`

## Known Issues

See **TEST_ERRORS_README.md** for complete list of known issues.

## Next Steps

1. Run all ChatGPT test prompts
2. Document all findings
3. Fix identified issues
4. Re-test after fixes
5. Create automated test suite


