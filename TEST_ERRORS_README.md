# Kothari API Framework - Test Errors & Issues Log

This document tracks all errors and issues discovered during framework testing.

## Initial Error Encountered

### Error: `can't find file 'kothari_api'`

**Location:** `src/server.cr:1:1`

**Error Message:**
```
Error: can't find file 'kothari_api'

If you're trying to require a shard:
- Did you remember to run `shards install`?
- Did you make sure you're running the compiler in the same directory as your shard.yml?
```

**Root Cause:** 
The framework requires proper shard dependency setup. When generating a new app, the `shard.yml` is created with a path dependency pointing to the parent directory, but `shards install` must be run before compilation.

**Solution:**
1. Always run `shards install` after creating a new app
2. Ensure you're in the app root directory when running commands
3. Verify `lib/kothari_api` exists after `shards install`

## Framework Status

### ✅ Working Components

1. **CLI Build** - Framework CLI compiles successfully
2. **App Generation** - `kothari new <app_name>` creates app structure correctly
3. **Shard Installation** - Dependencies install correctly via `shards install`
4. **File Structure** - Generated app has correct directory structure:
   - `app/controllers/`
   - `app/models/`
   - `config/routes.cr`
   - `src/server.cr`
   - `db/migrations/`

### ⚠️ Known Issues

1. **Code Formatting** - Several files need formatting:
   - `src/kothari_api/controller.cr`
   - `src/kothari_api/controller_registry.cr`
   - `src/kothari_api/model.cr`
   - `src/kothari_api/model_registry.cr`
   - `src/kothari_api/storage.cr`
   - `src/kothari_api/validations.cr`

2. **Compilation Time** - Initial compilation can be slow (may timeout on first run)

3. **Path Dependencies** - When testing locally, ensure the framework path in `shard.yml` is correct:
   ```yaml
   dependencies:
     kothari_api:
       path: ..
   ```

## Test App Creation Steps

### Successful Test App Creation

```bash
# 1. Build the CLI
cd /var/crystal_programs/kothari_api
crystal build src/cli/kothari.cr -o kothari

# 2. Generate test app
./kothari new test_app

# 3. Install dependencies
cd test_app
shards install

# 4. Verify structure
ls -la
# Should show: app/, config/, db/, src/, shard.yml, etc.
```

### Generated Files Verification

✅ `src/server.cr` - Server entry point with `require "kothari_api"`
✅ `config/routes.cr` - Route definitions
✅ `app/controllers/home_controller.cr` - Default home controller
✅ `app/controllers.cr` - Controller auto-loader
✅ `app/models.cr` - Model auto-loader
✅ `shard.yml` - Dependency configuration

## Testing Checklist

### Basic Functionality Tests

- [ ] `kothari new <app_name>` - Creates app structure
- [ ] `shards install` - Installs dependencies
- [ ] `kothari server` - Starts development server
- [ ] `kothari build` - Compiles application
- [ ] `kothari routes` - Lists routes
- [ ] `kothari console` - Opens interactive console

### Generator Tests

- [ ] `kothari g controller <name>` - Generates controller
- [ ] `kothari g model <name> [fields]` - Generates model
- [ ] `kothari g migration <name> [fields]` - Generates migration
- [ ] `kothari g scaffold <name> [fields]` - Generates full scaffold
- [ ] `kothari g auth` - Generates authentication

### Database Tests

- [ ] `kothari db:migrate` - Runs migrations
- [ ] `kothari db:reset` - Resets database
- [ ] Model CRUD operations work
- [ ] Database connections work

### Server Tests

- [ ] Server starts on default port (3000)
- [ ] Server accepts custom port (`-p` or `--port`)
- [ ] Routes respond correctly
- [ ] Controllers handle requests
- [ ] JSON responses work
- [ ] Error handling works

### Framework Core Tests

- [ ] `KothariAPI::Controller` - Controller base class
- [ ] `KothariAPI::Model` - Model base class
- [ ] `KothariAPI::Router` - Routing system
- [ ] `KothariAPI::DB` - Database connection
- [ ] `KothariAPI::Auth::JWT` - JWT authentication
- [ ] `KothariAPI::Auth::Password` - Password hashing
- [ ] `KothariAPI::Validations` - Validation helpers
- [ ] `KothariAPI::Storage` - File storage

## Error Log

### Error #1: Missing Shard Dependency
- **Date:** Initial test
- **Error:** `can't find file 'kothari_api'`
- **Status:** ✅ Resolved (requires `shards install`)
- **Fix:** Documented in README that `shards install` is required

### Error #2: Code Formatting Issues
- **Date:** Initial test
- **Error:** Multiple files need formatting
- **Status:** ⚠️ Needs fixing
- **Files Affected:** 6 files in `src/kothari_api/`

### Error #3: Slow Compilation
- **Date:** Initial test
- **Error:** Compilation times out on first run
- **Status:** ⚠️ Performance issue
- **Note:** May be normal for first compilation, needs verification

## Next Steps

1. Fix code formatting issues
2. Test all CLI commands end-to-end
3. Verify all framework components work
4. Test with multiple app scenarios
5. Performance testing
6. Error handling verification

## Notes

- Framework appears to be functional but needs comprehensive testing
- All major components are in place
- Documentation is good but testing coverage needed
- Consider adding automated tests


