# Performance Measurement Results

## Test Environment

- **Database**: PostgreSQL 15
- **Data**: 2,000 categories + 100,000 items
- **JVM**: Java 21
- **Connection Pool**: HikariCP (max 20 connections)
- **L2 Cache**: Disabled
- **Hardware**: [TO FILL]
  - CPU: 
  - RAM: 
  - OS: 

## Measurement Tables

### T0: Scenario 1 - READ Heavy (50% GET items, 20% GET items by category, 20% GET category items, 10% GET categories)

| Variant | RPS | p50 (ms) | p95 (ms) | p99 (ms) | Error % | CPU % | RAM (MB) | GC Count | GC Time (ms) | Threads |
|---------|-----|----------|----------|----------|---------|-------|----------|----------|--------------|---------|
| A - Jersey | | | | | | | | | | |
| C - Spring @RestController | | | | | | | | | | |
| D - Spring Data REST | | | | | | | | | | |

**Load Profile**: 50→100→200 threads, 60s ramp-up, 10min plateau

---

### T1: Scenario 2 - JOIN Filter (70% GET items by category, 30% GET item by ID)

| Variant | RPS | p50 (ms) | p95 (ms) | p99 (ms) | Error % | CPU % | RAM (MB) | GC Count | GC Time (ms) | Threads |
|---------|-----|----------|----------|----------|---------|-------|----------|----------|--------------|---------|
| A - Jersey | | | | | | | | | | |
| C - Spring @RestController | | | | | | | | | | |
| D - Spring Data REST | | | | | | | | | | |

**Load Profile**: 60→120 threads, 60s ramp-up, 10min duration

---

### T2: Scenario 3 - Mixed Operations (60% GET, 20% POST, 15% PUT, 5% DELETE)

| Variant | RPS | p50 (ms) | p95 (ms) | p99 (ms) | Error % | CPU % | RAM (MB) | GC Count | GC Time (ms) | Threads |
|---------|-----|----------|----------|----------|---------|-------|----------|----------|--------------|---------|
| A - Jersey | | | | | | | | | | |
| C - Spring @RestController | | | | | | | | | | |
| D - Spring Data REST | | | | | | | | | | |

**Payload Size**: ~1 KB  
**Load Profile**: 50→100 threads, 60s ramp-up, 10min duration

---

### T3: Scenario 4 - Heavy Body (50% POST 5KB, 30% PUT 5KB, 20% GET)

| Variant | RPS | p50 (ms) | p95 (ms) | p99 (ms) | Error % | CPU % | RAM (MB) | GC Count | GC Time (ms) | Threads |
|---------|-----|----------|----------|----------|---------|-------|----------|----------|--------------|---------|
| A - Jersey | | | | | | | | | | |
| C - Spring @RestController | | | | | | | | | | |
| D - Spring Data REST | | | | | | | | | | |

**Payload Size**: ~5 KB  
**Load Profile**: 30→60 threads, 60s ramp-up, 10min duration

---

### T4: GET /items?page=0&size=50 (Single Endpoint Benchmark)

| Variant | RPS | p50 (ms) | p95 (ms) | p99 (ms) | Error % | CPU % | RAM (MB) |
|---------|-----|----------|----------|----------|---------|-------|----------|
| A - Jersey | | | | | | | |
| C - Spring @RestController | | | | | | | |
| D - Spring Data REST | | | | | | | |

**Load**: 100 threads, 5min duration

---

### T5: GET /items/{id} (Single Item Lookup)

| Variant | RPS | p50 (ms) | p95 (ms) | p99 (ms) | Error % | CPU % | RAM (MB) |
|---------|-----|----------|----------|----------|---------|-------|----------|
| A - Jersey | | | | | | | |
| C - Spring @RestController | | | | | | | |
| D - Spring Data REST | | | | | | | |

**Load**: 100 threads, 5min duration

---

### T6: POST /items (Write Performance)

| Variant | RPS | p50 (ms) | p95 (ms) | p99 (ms) | Error % | CPU % | RAM (MB) |
|---------|-----|----------|----------|----------|---------|-------|----------|
| A - Jersey | | | | | | | |
| C - Spring @RestController | | | | | | | |
| D - Spring Data REST | | | | | | | |

**Payload**: 1 KB  
**Load**: 50 threads, 5min duration

---

## How to Collect Metrics

### 1. JMeter Metrics (RPS, Latency, Error Rate)

After running a test:
```bash
# Generate HTML report
jmeter -g results/s1-jersey.jtl -o results/s1-jersey-report

# Extract key metrics from .jtl file
grep -v "^timeStamp" results/s1-jersey.jtl | awk -F',' '{sum+=$2; count++} END {print "Avg Response Time:", sum/count "ms"}'
```

Or use JMeter GUI:
1. Open JMeter
2. Add → Listener → Summary Report
3. Load .jtl file
4. View metrics

### 2. Grafana Metrics (CPU, RAM, GC, Threads)

1. Access Grafana: http://localhost:3000
2. During test execution, monitor:
   - **CPU**: `process_cpu_usage` or `system_cpu_usage`
   - **RAM**: `jvm_memory_used_bytes` / 1024 / 1024
   - **GC Count**: `jvm_gc_pause_seconds_count`
   - **GC Time**: `jvm_gc_pause_seconds_sum` * 1000
   - **Threads**: `jvm_threads_live`

3. Export data or take screenshots

### 3. Prometheus Queries

```promql
# RPS
rate(http_server_requests_seconds_count[1m])

# p50 latency
histogram_quantile(0.50, rate(http_server_requests_seconds_bucket[1m]))

# p95 latency
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[1m]))

# p99 latency
histogram_quantile(0.99, rate(http_server_requests_seconds_bucket[1m]))

# CPU usage
process_cpu_usage

# Memory
jvm_memory_used_bytes{area="heap"} / 1024 / 1024

# GC
rate(jvm_gc_pause_seconds_count[1m])
```

## Notes

- Run each test 3 times and take the median values
- Ensure no other applications are running during tests
- Restart the service between tests to clear any state
- Monitor database performance separately if needed
- Wait 2-3 minutes between tests for system stabilization
