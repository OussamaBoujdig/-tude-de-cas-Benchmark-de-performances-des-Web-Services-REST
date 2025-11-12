# JMeter Test Plans

This directory contains 4 JMeter test scenarios for REST API performance testing.

## Prerequisites

- Apache JMeter 5.6+ installed
- One variant service running (port 8081, 8082, or 8083)
- Database populated with test data

## Test Scenarios

### Scenario 1: READ Heavy
**File**: `scenario1-read-heavy.jmx`

- **Distribution**:
  - 50% GET /items?page=&size=50
  - 20% GET /items?categoryId=
  - 20% GET /categories/{id}/items
  - 10% GET /categories

- **Load Profile**:
  - Threads: 50 → 100 → 200
  - Ramp-up: 60 seconds
  - Duration: 10 minutes plateau

**Run**:
```bash
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l results/s1-variant-a.jtl -e -o results/s1-variant-a-report
```

### Scenario 2: JOIN Filter
**File**: `scenario2-join-filter.jmx`

- **Distribution**:
  - 70% GET /items?categoryId=
  - 30% GET /items/{id}

- **Load Profile**:
  - Threads: 60 → 120
  - Ramp-up: 60 seconds
  - Duration: 10 minutes

**Run**:
```bash
jmeter -n -t scenario2-join-filter.jmx -Jhost=localhost -Jport=8081 -l results/s2-variant-a.jtl -e -o results/s2-variant-a-report
```

### Scenario 3: Mixed Operations
**File**: `scenario3-mixed.jmx`

- **Distribution**:
  - 60% GET requests
  - 20% POST requests
  - 15% PUT requests
  - 5% DELETE requests

- **Payload**: ~1 KB
- **Load Profile**:
  - Threads: 50 → 100
  - Duration: 10 minutes

**Run**:
```bash
jmeter -n -t scenario3-mixed.jmx -Jhost=localhost -Jport=8081 -l results/s3-variant-a.jtl -e -o results/s3-variant-a-report
```

### Scenario 4: Heavy Body
**File**: `scenario4-heavy-body.jmx`

- **Distribution**:
  - 50% POST with 5 KB payload
  - 30% PUT with 5 KB payload
  - 20% GET requests

- **Load Profile**:
  - Threads: 30 → 60
  - Duration: 10 minutes

**Run**:
```bash
jmeter -n -t scenario4-heavy-body.jmx -Jhost=localhost -Jport=8081 -l results/s4-variant-a.jtl -e -o results/s4-variant-a-report
```

## Running Tests for All Variants

### Variant A (Jersey) - Port 8081
```bash
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l results/s1-jersey.jtl
jmeter -n -t scenario2-join-filter.jmx -Jhost=localhost -Jport=8081 -l results/s2-jersey.jtl
jmeter -n -t scenario3-mixed.jmx -Jhost=localhost -Jport=8081 -l results/s3-jersey.jtl
jmeter -n -t scenario4-heavy-body.jmx -Jhost=localhost -Jport=8081 -l results/s4-jersey.jtl
```

### Variant C (Spring) - Port 8082
```bash
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8082 -l results/s1-spring.jtl
jmeter -n -t scenario2-join-filter.jmx -Jhost=localhost -Jport=8082 -l results/s2-spring.jtl
jmeter -n -t scenario3-mixed.jmx -Jhost=localhost -Jport=8082 -l results/s3-spring.jtl
jmeter -n -t scenario4-heavy-body.jmx -Jhost=localhost -Jport=8082 -l results/s4-spring.jtl
```

### Variant D (Spring Data) - Port 8083
```bash
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8083 -l results/s1-springdata.jtl
jmeter -n -t scenario2-join-filter.jmx -Jhost=localhost -Jport=8083 -l results/s2-springdata.jtl
jmeter -n -t scenario3-mixed.jmx -Jhost=localhost -Jport=8083 -l results/s3-springdata.jtl
jmeter -n -t scenario4-heavy-body.jmx -Jhost=localhost -Jport=8083 -l results/s4-springdata.jtl
```

## Analyzing Results

JMeter generates `.jtl` files with raw results. To generate HTML reports:

```bash
jmeter -g results/s1-jersey.jtl -o results/s1-jersey-report
```

Key metrics to extract:
- **RPS**: Throughput (requests/second)
- **Latency**: p50, p95, p99 percentiles
- **Error Rate**: % of failed requests
- **Response Time**: Average, Min, Max

Monitor Grafana dashboard during tests for:
- CPU usage
- RAM usage
- GC count and time
- Thread count
- HikariCP connection pool metrics
