# Complete Setup and Execution Guide

This guide walks you through setting up and running the complete REST API performance comparison.

## Prerequisites

- Java 21 JDK
- Maven 3.8+
- PostgreSQL 15+ (or Docker)
- Apache JMeter 5.6+
- Python 3.8+ (for JMeter test generation)
- Docker & Docker Compose (optional, for monitoring)

---

## Step 1: Database Setup

### Option A: Docker PostgreSQL

```bash
cd monitoring
docker-compose up -d postgres
```

Wait 10 seconds for PostgreSQL to start, then verify:
```bash
docker exec -it postgres-perf psql -U perfuser -d rest_api_perf -c "SELECT version();"
```

### Option B: Local PostgreSQL

1. Install PostgreSQL 15+
2. Create database and user:
```sql
CREATE DATABASE rest_api_perf;
CREATE USER perfuser WITH PASSWORD 'perfpass';
GRANT ALL PRIVILEGES ON DATABASE rest_api_perf TO perfuser;
```

### Initialize Schema

```bash
cd database
psql -h localhost -U perfuser -d rest_api_perf -f schema.sql
```

Expected output: "Schema created successfully"

---

## Step 2: Generate Test Data

### Option A: SQL Script (Fastest)

```bash
cd database
psql -h localhost -U perfuser -d rest_api_perf -f generate-data.sql
```

This generates:
- 2,000 categories
- 100,000 items

**Time**: ~30-60 seconds

### Option B: Java Generator

```bash
cd database
mvn clean package
java -jar target/data-generator-1.0.0.jar
```

**Time**: ~2-3 minutes

### Verify Data

```bash
psql -h localhost -U perfuser -d rest_api_perf -c "SELECT COUNT(*) FROM category;"
psql -h localhost -U perfuser -d rest_api_perf -c "SELECT COUNT(*) FROM item;"
```

Expected:
- Categories: 2000
- Items: 100000

---

## Step 3: Build Common Module

```bash
cd common
mvn clean install
```

This installs the shared domain models to your local Maven repository.

---

## Step 4: Build and Run Variants

### Variant A: Jersey (JAX-RS) - Port 8081

```bash
cd variant-a-jersey
mvn clean package
mvn spring-boot:run
```

Verify:
```bash
curl http://localhost:8081/actuator/health
curl http://localhost:8081/items?page=0&size=10
```

### Variant C: Spring @RestController - Port 8082

```bash
cd variant-c-spring
mvn clean package
mvn spring-boot:run
```

Verify:
```bash
curl http://localhost:8082/actuator/health
curl http://localhost:8082/items?page=0&size=10
```

### Variant D: Spring Data REST - Port 8083

```bash
cd variant-d-spring-data
mvn clean package
mvn spring-boot:run
```

Verify:
```bash
curl http://localhost:8083/actuator/health
curl http://localhost:8083/items?page=0&size=10
```

**Note**: Run only ONE variant at a time during performance tests.

---

## Step 5: Setup Monitoring

### Start Prometheus and Grafana

```bash
cd monitoring
docker-compose up -d prometheus grafana
```

### Access Monitoring Tools

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)

### Configure Grafana

1. Login to Grafana (admin/admin)
2. Data source should be auto-configured (Prometheus)
3. Create dashboard or import JVM dashboard:
   - Dashboard ID: 4701 (JVM Micrometer)
   - Or ID: 11378 (JVM Dashboard)

### Verify Metrics

In Prometheus, check if targets are UP:
- http://localhost:9090/targets

You should see the variant you're running (e.g., variant-a-jersey).

---

## Step 6: Generate JMeter Test Plans

```bash
cd jmeter
python generate-jmx.py
```

This creates:
- `scenario1-read-heavy.jmx`
- `scenario2-join-filter.jmx`
- `scenario3-mixed.jmx`
- `scenario4-heavy-body.jmx`

---

## Step 7: Run Performance Tests

### Test Execution Order

For each variant (A, C, D):

1. **Start the variant** (e.g., `cd variant-a-jersey && mvn spring-boot:run`)
2. **Wait 30 seconds** for warmup
3. **Run test scenarios** one by one
4. **Wait 2-3 minutes** between tests
5. **Stop the variant**
6. **Repeat for next variant**

### Example: Testing Variant A (Jersey)

```bash
# Terminal 1: Start variant
cd variant-a-jersey
mvn spring-boot:run

# Terminal 2: Run tests (wait 30s after startup)
cd jmeter

# Scenario 1: READ Heavy
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 \
  -l ../results/s1-jersey.jtl -e -o ../results/s1-jersey-report

# Wait 3 minutes

# Scenario 2: JOIN Filter
jmeter -n -t scenario2-join-filter.jmx -Jhost=localhost -Jport=8081 \
  -l ../results/s2-jersey.jtl -e -o ../results/s2-jersey-report

# Wait 3 minutes

# Scenario 3: Mixed
jmeter -n -t scenario3-mixed.jmx -Jhost=localhost -Jport=8081 \
  -l ../results/s3-jersey.jtl -e -o ../results/s3-jersey-report

# Wait 3 minutes

# Scenario 4: Heavy Body
jmeter -n -t scenario4-heavy-body.jmx -Jhost=localhost -Jport=8081 \
  -l ../results/s4-jersey.jtl -e -o ../results/s4-jersey-report
```

### Testing Variant C (Spring)

```bash
# Stop Variant A, start Variant C
cd variant-c-spring
mvn spring-boot:run

# Run same tests with -Jport=8082
cd jmeter
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8082 \
  -l ../results/s1-spring.jtl -e -o ../results/s1-spring-report
# ... repeat for all scenarios
```

### Testing Variant D (Spring Data)

```bash
# Stop Variant C, start Variant D
cd variant-d-spring-data
mvn spring-boot:run

# Run same tests with -Jport=8083
cd jmeter
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8083 \
  -l ../results/s1-springdata.jtl -e -o ../results/s1-springdata-report
# ... repeat for all scenarios
```

---

## Step 8: Collect Metrics

### From JMeter Reports

Open the HTML reports:
```bash
# Example for Scenario 1, Jersey
cd results/s1-jersey-report
# Open index.html in browser
```

Extract key metrics:
- **RPS**: Look at "Throughput" in Summary Report
- **p50/p95/p99**: Look at "Response Time Percentiles"
- **Error %**: Look at "Error %" in Summary Report

### From Grafana

During each test:
1. Open Grafana dashboard
2. Set time range to test duration
3. Record:
   - CPU usage (average during plateau)
   - Memory usage (peak heap)
   - GC count (total during test)
   - GC time (total pause time)
   - Thread count (average)

### From Prometheus

Query examples:
```promql
# Average RPS during test
rate(http_server_requests_seconds_count{job="variant-a-jersey"}[5m])

# p99 latency
histogram_quantile(0.99, rate(http_server_requests_seconds_bucket[5m]))

# CPU usage
avg_over_time(process_cpu_usage{job="variant-a-jersey"}[10m])

# Memory
avg_over_time(jvm_memory_used_bytes{area="heap",job="variant-a-jersey"}[10m]) / 1024 / 1024
```

---

## Step 9: Fill Measurement Tables

Open `results/MEASUREMENTS.md` and fill in the tables with collected data.

For each variant and scenario, record:
- RPS (from JMeter)
- p50, p95, p99 latency (from JMeter)
- Error % (from JMeter)
- CPU % (from Grafana/Prometheus)
- RAM MB (from Grafana/Prometheus)
- GC Count (from Grafana/Prometheus)
- GC Time (from Grafana/Prometheus)
- Threads (from Grafana/Prometheus)

---

## Step 10: Analyze Results

1. Review completed `MEASUREMENTS.md`
2. Read `ANALYSIS.md` for interpretation guidelines
3. Compare variants across scenarios
4. Identify performance patterns
5. Document conclusions

---

## Troubleshooting

### Database Connection Issues

```bash
# Check PostgreSQL is running
docker ps | grep postgres
# Or for local: sudo systemctl status postgresql

# Test connection
psql -h localhost -U perfuser -d rest_api_perf -c "SELECT 1;"
```

### Port Already in Use

```bash
# Check what's using the port
netstat -ano | findstr :8081

# Kill process if needed (Windows)
taskkill /PID <PID> /F
```

### JMeter Out of Memory

Edit `jmeter.bat` (Windows) or `jmeter` (Linux):
```bash
# Increase heap size
set HEAP=-Xms1g -Xmx4g
```

### Variant Won't Start

```bash
# Check logs
cd variant-a-jersey
mvn spring-boot:run

# Look for errors in console
# Common issues:
# - Database not accessible
# - Port already in use
# - Common module not installed
```

### No Metrics in Prometheus

1. Check variant is running: `curl http://localhost:8081/actuator/prometheus`
2. Check Prometheus config: `monitoring/prometheus.yml`
3. Restart Prometheus: `docker-compose restart prometheus`
4. Check targets: http://localhost:9090/targets

---

## Quick Test Script (Windows PowerShell)

```powershell
# test-all-variants.ps1
$variants = @(
    @{Name="Jersey"; Port=8081; Path="variant-a-jersey"},
    @{Name="Spring"; Port=8082; Path="variant-c-spring"},
    @{Name="SpringData"; Port=8083; Path="variant-d-spring-data"}
)

$scenarios = @("scenario1-read-heavy", "scenario2-join-filter", "scenario3-mixed", "scenario4-heavy-body")

foreach ($variant in $variants) {
    Write-Host "Testing $($variant.Name)..." -ForegroundColor Green
    
    # Start variant (in background)
    Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run" -WorkingDirectory $variant.Path
    
    Start-Sleep -Seconds 30  # Warmup
    
    foreach ($scenario in $scenarios) {
        Write-Host "  Running $scenario..." -ForegroundColor Yellow
        
        $resultFile = "results\$scenario-$($variant.Name.ToLower()).jtl"
        $reportDir = "results\$scenario-$($variant.Name.ToLower())-report"
        
        jmeter -n -t "jmeter\$scenario.jmx" `
               -Jhost=localhost -Jport=$($variant.Port) `
               -l $resultFile -e -o $reportDir
        
        Start-Sleep -Seconds 180  # Wait between tests
    }
    
    # Stop variant
    Stop-Process -Name "java" -Force
    Start-Sleep -Seconds 10
}

Write-Host "All tests completed!" -ForegroundColor Green
```

---

## Expected Timeline

- **Setup** (first time): 30-60 minutes
- **Per variant testing**: 60-90 minutes (4 scenarios × 15 min each)
- **Total testing time**: 3-4 hours (all 3 variants)
- **Analysis**: 1-2 hours

---

## Best Practices

1. **Consistent environment**: Close unnecessary applications
2. **Warmup**: Always wait 30s after starting a variant
3. **Cooldown**: Wait 2-3 minutes between tests
4. **Multiple runs**: Run each test 3 times, use median values
5. **Monitor**: Keep Grafana open during tests
6. **Document**: Note any anomalies or issues
7. **Backup**: Save all .jtl files and reports

---

## Next Steps After Testing

1. Review `results/MEASUREMENTS.md` with filled data
2. Read `results/ANALYSIS.md` for conclusions
3. Make architectural decision based on your specific requirements
4. Consider running additional custom scenarios if needed
5. Share results with team for discussion

---

**Good luck with your performance testing!** 🚀
