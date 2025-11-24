# KothariAPI Performance Benchmarks

## Test Environment

- **Framework**: KothariAPI v0.1.0
- **Language**: Crystal 1.x
- **Database**: SQLite3
- **Server**: Built with `--release` flag (optimized)
- **Test Machine**: Linux (WSL2)
- **Concurrent Connections**: 10
- **Total Requests per Test**: 1,000

## Benchmark Results

### Test 1: Simple JSON Response (GET /)

**Endpoint**: `GET /` - Returns simple JSON without database access

| Metric | Value |
|--------|-------|
| Requests/sec | ~XX,XXX req/s |
| Average Latency | X.XX ms |
| P50 Latency | X.XX ms |
| P95 Latency | X.XX ms |
| P99 Latency | X.XX ms |
| Min Latency | X.XX ms |
| Max Latency | X.XX ms |

**Analysis**: This test measures raw HTTP handling and JSON serialization performance without database overhead.

---

### Test 2: Database Query - List All (GET /articles)

**Endpoint**: `GET /articles` - Queries all records from database

| Metric | Value |
|--------|-------|
| Requests/sec | ~XX,XXX req/s |
| Average Latency | X.XX ms |
| P50 Latency | X.XX ms |
| P95 Latency | X.XX ms |
| P99 Latency | X.XX ms |
| Min Latency | X.XX ms |
| Max Latency | X.XX ms |

**Analysis**: Tests ORM query performance and JSON serialization of model collections.

---

### Test 3: Database Write (POST /articles)

**Endpoint**: `POST /articles` - Creates new record in database

| Metric | Value |
|--------|-------|
| Requests/sec | ~XX,XXX req/s |
| Average Latency | X.XX ms |
| P50 Latency | X.XX ms |
| P95 Latency | X.XX ms |
| P99 Latency | X.XX ms |
| Min Latency | X.XX ms |
| Max Latency | X.XX ms |

**Analysis**: Tests database INSERT performance with parameterized queries and model instantiation.

---

### Test 4: Authentication - Signup (POST /signup)

**Endpoint**: `POST /signup` - Password hashing + JWT generation + database write

| Metric | Value |
|--------|-------|
| Requests/sec | ~XX,XXX req/s |
| Average Latency | X.XX ms |
| P50 Latency | X.XX ms |
| P95 Latency | X.XX ms |
| P99 Latency | X.XX ms |
| Min Latency | X.XX ms |
| Max Latency | X.XX ms |

**Analysis**: Tests cryptographic operations (SHA-256 password hashing with salt + pepper) and JWT token generation, plus database write.

---

### Test 5: Authentication - Login (POST /login)

**Endpoint**: `POST /login` - Password verification + JWT generation

| Metric | Value |
|--------|-------|
| Requests/sec | ~XX,XXX req/s |
| Average Latency | X.XX ms |
| P50 Latency | X.XX ms |
| P95 Latency | X.XX ms |
| P99 Latency | X.XX ms |
| Min Latency | X.XX ms |
| Max Latency | X.XX ms |

**Analysis**: Tests password verification (constant-time comparison) and JWT token generation.

---

## Performance Characteristics

### Strengths

1. **High Throughput**: Crystal's compiled nature and fiber-based concurrency enable excellent request handling
2. **Low Latency**: Minimal overhead from framework abstraction
3. **Efficient Database Operations**: Parameterized queries and direct SQL execution
4. **Fast JSON Serialization**: Crystal's built-in JSON support is highly optimized
5. **Cryptographic Performance**: OpenSSL-based password hashing is efficient

### Comparison Context

KothariAPI is designed for:
- **API-first applications** requiring high performance
- **Microservices** where low latency matters
- **Real-time applications** needing consistent response times
- **High-traffic endpoints** requiring maximum throughput

## Running Your Own Benchmarks

```bash
# 1. Create a new app
kothari new my_benchmark_app
cd my_benchmark_app
shards install

# 2. Generate test resources
kothari g scaffold article title:string content:text
kothari db:migrate

# 3. Build optimized server
crystal build --release src/server.cr -o server

# 4. Start server
./server

# 5. Run benchmark (in another terminal)
crystal run benchmark.cr
```

## Notes

- All tests run with `--release` flag for production-like performance
- SQLite3 is used for simplicity; PostgreSQL/MySQL would show different characteristics
- Results may vary based on hardware, OS, and system load
- For production deployments, consider connection pooling and database optimization

---

**Last Updated**: $(date)
**Framework Version**: 0.1.0
**Crystal Version**: $(crystal --version)




