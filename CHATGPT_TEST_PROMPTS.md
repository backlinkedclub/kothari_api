# ChatGPT Test Prompts for Kothari API Framework

This document contains comprehensive test prompts to give to ChatGPT for testing the Kothari API Framework. Each prompt tests specific functionality.

## Setup Instructions for ChatGPT

Before running tests, provide this context:

```
I have a Crystal web framework called "Kothari API" that I need you to test. 
The framework is located at /var/crystal_programs/kothari_api.

The framework has a CLI tool called "kothari" that can be built with:
crystal build src/cli/kothari.cr -o kothari

The framework supports these commands:
- kothari new <app_name> - Create new app
- kothari server [-p|--port PORT] - Start server
- kothari build [output] [--release] - Build binary
- kothari g controller <name> - Generate controller
- kothari g model <name> [field:type ...] - Generate model
- kothari g migration <name> [field:type ...] - Generate migration
- kothari g scaffold <name> [field:type ...] - Generate scaffold
- kothari g auth [name] - Generate authentication
- kothari db:migrate - Run migrations
- kothari db:reset - Reset database
- kothari routes - List routes
- kothari document - Generate API docs
- kothari console - Open console
- kothari benchmark - Run benchmarks

Please test each component systematically and report any errors or issues.
```

---

## Test Prompt 1: Basic Framework Setup

```
Test the basic framework setup:

1. Navigate to /var/crystal_programs/kothari_api
2. Build the CLI: crystal build src/cli/kothari.cr -o kothari
3. Verify the binary was created and is executable
4. Run: ./kothari help
5. Verify the help menu displays correctly
6. Check that all commands are listed

Report any errors or missing commands.
```

---

## Test Prompt 2: App Generation

```
Test app generation:

1. Navigate to /var/crystal_programs/kothari_api
2. Run: ./kothari new test_app_basic
3. Verify the app directory was created
4. Check that these directories exist:
   - test_app_basic/app/controllers
   - test_app_basic/app/models
   - test_app_basic/config
   - test_app_basic/src
   - test_app_basic/db/migrations
5. Verify these files were created:
   - test_app_basic/src/server.cr
   - test_app_basic/config/routes.cr
   - test_app_basic/app/controllers/home_controller.cr
   - test_app_basic/shard.yml
6. Check that shard.yml has correct dependency on kothari_api
7. Navigate to test_app_basic and run: shards install
8. Verify shards install successfully

Report any missing files, incorrect structure, or installation errors.
```

---

## Test Prompt 3: Server Startup

```
Test server startup:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Ensure shards are installed (run shards install if needed)
3. Run: ../kothari server
4. Verify server starts without errors
5. Check that it listens on port 3000 (or shows port in use message)
6. Test with custom port: ../kothari server -p 3001
7. Verify server accepts the custom port
8. Test with --port flag: ../kothari server --port 3002
9. Verify server accepts the --port flag

Report any startup errors, port binding issues, or compilation errors.
```

---

## Test Prompt 4: Basic Route and Controller

```
Test basic routing and controller:

1. Start the server in test_app_basic (from previous test)
2. Make HTTP request to: GET http://localhost:3000/
3. Verify response is JSON: {"message":"Welcome to KothariAPI"}
4. Verify status code is 200
5. Check server logs for any errors
6. Test invalid route: GET http://localhost:3000/invalid
7. Verify 404 response with JSON error

Report any routing errors, controller errors, or incorrect responses.
```

---

## Test Prompt 5: Controller Generator

```
Test controller generation:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Run: ../kothari g controller blog
3. Verify file created: app/controllers/blog_controller.cr
4. Check controller has index method
5. Verify route was added to config/routes.cr
6. Check route is: GET /blog -> blog#index
7. Restart server and test: GET http://localhost:3000/blog
8. Verify controller responds correctly

Report any generation errors, missing files, or incorrect route registration.
```

---

## Test Prompt 6: Model Generator

```
Test model generation:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Run: ../kothari g model post title:string content:text views:integer
3. Verify file created: app/models/post.cr
4. Check model has:
   - Table name "posts"
   - Fields: title (String), content (String), views (Int32)
   - Timestamps (created_at, updated_at)
   - Model registration
5. Verify model can be required without errors
6. Test in console: ../kothari console
7. Run: models
8. Verify "post" is listed
9. Test: Post.all (should return empty array)

Report any generation errors, missing fields, or model registration issues.
```

---

## Test Prompt 7: Migration Generator

```
Test migration generation:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Run: ../kothari g migration create_posts title:string content:text views:integer
3. Verify migration file created in db/migrations/
4. Check migration file has:
   - Proper timestamp prefix
   - CREATE TABLE statement
   - Correct column types
   - created_at and updated_at columns
5. Run: ../kothari db:migrate
6. Verify migration runs without errors
7. Check database file exists: db/development.sqlite3
8. Verify table "posts" exists in database
9. Check table has correct columns

Report any migration errors, incorrect SQL, or database issues.
```

---

## Test Prompt 8: Scaffold Generator

```
Test scaffold generation:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Run: ../kothari g scaffold article title:string body:text published:bool
3. Verify all files created:
   - app/models/article.cr
   - app/controllers/articles_controller.cr
   - db/migrations/[timestamp]_create_articles.cr
4. Check routes were added to config/routes.cr:
   - GET /articles
   - POST /articles
5. Run: ../kothari db:migrate
6. Verify migration succeeds
7. Restart server
8. Test endpoints:
   - GET /articles (should return empty array)
   - POST /articles with JSON body
   - GET /articles/:id
   - PATCH /articles/:id
   - DELETE /articles/:id

Report any missing files, incorrect routes, or CRUD operation errors.
```

---

## Test Prompt 9: Authentication Generator

```
Test authentication generation:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Run: ../kothari g auth
3. Verify files created:
   - app/models/user.cr
   - app/controllers/auth_controller.cr
   - Migration for users table
4. Check User model has:
   - email field
   - password_digest field
   - Password hashing methods
5. Check AuthController has:
   - signup method
   - login method
6. Verify routes added:
   - POST /signup
   - POST /login
7. Run: ../kothari db:migrate
8. Restart server
9. Test signup: POST /signup with {"email":"test@example.com","password":"test123"}
10. Verify user created and JWT token returned
11. Test login: POST /login with same credentials
12. Verify JWT token returned

Report any authentication errors, missing methods, or JWT issues.
```

---

## Test Prompt 10: Database Operations

```
Test database operations:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Ensure scaffold was created (from Test 8) and migrated
3. Open console: ../kothari console
4. Test model queries:
   - Article.all
   - Article.find(1) (should return nil if no records)
   - Article.where("published = 1")
5. Create record via API: POST /articles
6. In console, verify: Article.all (should show new record)
7. Test: Article.find(1) (should return the record)
8. Test update via API: PATCH /articles/1
9. In console, verify changes: Article.find(1)
10. Test delete via API: DELETE /articles/1
11. In console, verify: Article.all (should be empty)

Report any database query errors, model method failures, or data persistence issues.
```

---

## Test Prompt 11: Routes Command

```
Test routes listing:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Run: ../kothari routes
3. Verify routes table displays correctly
4. Check all routes are listed:
   - GET /
   - GET /blog (if controller generated)
   - GET /articles (if scaffold generated)
   - POST /articles
   - POST /signup (if auth generated)
   - POST /login (if auth generated)
5. Verify format is correct (Method, Path, Controller#Action)
6. Check total count matches

Report any missing routes, formatting issues, or command errors.
```

---

## Test Prompt 12: Build Command

```
Test build command:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Run: ../kothari build
3. Verify binary is created (default name or app name)
4. Check binary is executable
5. Run the binary: ./test_app_basic (or ./[binary_name])
6. Verify server starts
7. Test: ../kothari build myapp --release
8. Verify release binary is created
9. Check binary size (release should be optimized)
10. Run release binary and verify it works

Report any build errors, missing binaries, or execution issues.
```

---

## Test Prompt 13: Console Command

```
Test console command:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Run: ../kothari console
3. Verify console starts
4. Test commands:
   - help (should show help menu)
   - models (should list registered models)
   - Article.all (if scaffold exists)
   - sql SELECT * FROM articles
   - exit
5. Verify all commands work correctly
6. Test error handling with invalid commands

Report any console errors, command failures, or database connection issues.
```

---

## Test Prompt 14: Document Command

```
Test documentation generation:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Ensure app has routes (from previous tests)
3. Run: ../kothari document
4. Verify README.md is updated or created
5. Check documentation includes:
   - All endpoints listed
   - HTTP methods
   - Paths
   - Controller actions
   - Example requests/responses
6. Verify format is readable and correct

Report any documentation errors, missing endpoints, or formatting issues.
```

---

## Test Prompt 15: Database Reset

```
Test database reset:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Ensure database has data (create some records via API)
3. Verify: Article.all returns records
4. Run: ../kothari db:reset
5. Verify database is dropped and recreated
6. Verify all migrations run
7. Check: Article.all returns empty array
8. Verify database file exists and is fresh

Report any reset errors, migration failures, or data persistence issues.
```

---

## Test Prompt 16: Error Handling

```
Test error handling:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Start server
3. Test various error scenarios:
   - Invalid JSON in POST request
   - Missing required fields
   - Invalid route
   - Invalid ID in URL
   - Database constraint violations
4. Verify all errors return proper JSON error responses
5. Check status codes are correct:
   - 400 for bad requests
   - 404 for not found
   - 422 for validation errors
   - 500 for server errors
6. Verify error messages are helpful

Report any unhandled errors, incorrect status codes, or poor error messages.
```

---

## Test Prompt 17: Framework Core Components

```
Test framework core components directly:

1. Navigate to /var/crystal_programs/kothari_api
2. Create a test script that requires and tests:
   - KothariAPI::Controller - Can instantiate
   - KothariAPI::Model - Can create model class
   - KothariAPI::Router - Can define routes
   - KothariAPI::DB - Can connect
   - KothariAPI::Auth::JWT - Can encode/decode tokens
   - KothariAPI::Auth::Password - Can hash/verify passwords
   - KothariAPI::Validations - Can validate data
   - KothariAPI::Storage - Can handle file storage
3. Run the test script
4. Verify all components load and basic methods work

Report any component loading errors, missing methods, or functionality issues.
```

---

## Test Prompt 18: Multiple App Scenario

```
Test framework with multiple apps:

1. Create two separate apps:
   - ./kothari new app1
   - ./kothari new app2
2. In app1: Generate scaffold for "product"
3. In app2: Generate scaffold for "order"
4. Install shards in both
5. Run migrations in both
6. Start both servers on different ports
7. Verify both apps work independently
8. Test that changes in one app don't affect the other

Report any conflicts, shared state issues, or dependency problems.
```

---

## Test Prompt 19: Performance and Stress Test

```
Test framework performance:

1. Navigate to /var/crystal_programs/kothari_api/test_app_basic
2. Start server
3. Run: ../kothari benchmark
4. Verify benchmark runs
5. Check performance metrics:
   - Response times
   - Throughput
   - Memory usage
6. Test with multiple concurrent requests
7. Test with large payloads
8. Monitor for memory leaks

Report any performance issues, slow responses, or memory problems.
```

---

## Test Prompt 20: Complete Integration Test

```
Complete end-to-end integration test:

1. Create fresh app: ./kothari new integration_test
2. cd integration_test && shards install
3. Generate auth: ../kothari g auth
4. Generate scaffold: ../kothari g scaffold post title:string content:text
5. Run migrations: ../kothari db:migrate
6. Start server: ../kothari server
7. Test complete flow:
   - Signup user
   - Login user (get JWT)
   - Create post (with JWT if auth required)
   - List posts
   - Get single post
   - Update post
   - Delete post
8. Verify all operations work
9. Check database state
10. Test error cases

Report any integration failures, missing features, or workflow issues.
```

---

## Test Prompt 21: Code Quality and Formatting

```
Test code quality:

1. Navigate to /var/crystal_programs/kothari_api
2. Run: crystal tool format --check src/kothari_api/*.cr
3. Fix any formatting issues
4. Run: crystal build --no-codegen src/kothari_api.cr
5. Check for compilation warnings
6. Verify no deprecated methods
7. Check for type safety issues
8. Review generated app code quality

Report any formatting issues, warnings, or code quality problems.
```

---

## Test Prompt 22: Edge Cases and Boundary Conditions

```
Test edge cases:

1. Test with very long field names
2. Test with special characters in routes
3. Test with empty strings
4. Test with null/optional fields
5. Test with maximum integer values
6. Test with unicode characters
7. Test with SQL injection attempts (should be safe)
8. Test with very large JSON payloads
9. Test with concurrent requests
10. Test server restart scenarios

Report any edge case failures or security vulnerabilities.
```

---

## Summary Prompt

```
After running all tests, provide a comprehensive summary:

1. List all errors found
2. Categorize errors by severity (Critical, High, Medium, Low)
3. List all working features
4. Provide recommendations for fixes
5. Estimate framework stability (1-10)
6. List missing features or improvements needed
7. Provide overall assessment

Format as a detailed test report.
```

---

## Usage Instructions

1. Copy each test prompt individually to ChatGPT
2. Run tests in order (they build on each other)
3. Document all results
4. Fix errors before moving to next test
5. Use the summary prompt at the end

## Notes

- Some tests require previous tests to be completed
- Keep test_app_basic for reference
- Create fresh apps for integration tests
- Document all findings in TEST_ERRORS_README.md


