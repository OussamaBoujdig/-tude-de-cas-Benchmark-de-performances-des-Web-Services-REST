# REST API Performance Comparison

This project compares three REST API implementations:
- **Variant A**: Jersey (JAX-RS)
- **Variant C**: Spring Boot @RestController
- **Variant D**: Spring Boot Spring Data REST

## Project Structure

```
rest-controller-api/
├── common/                    # Shared domain models and utilities
├── variant-a-jersey/          # Jersey JAX-RS implementation
├── variant-c-spring/          # Spring Boot @RestController
├── variant-d-spring-data/     # Spring Boot Spring Data REST
├── database/                  # Database schema and data generation
├── monitoring/                # Prometheus, Grafana configs
├── jmeter/                    # JMeter test plans
└── results/                   # Performance test results
```

## Database Setup

PostgreSQL 15+ required (local or Docker)

### Docker Setup
```bash
docker run --name postgres-perf \
  -e POSTGRES_DB=rest_api_perf \
  -e POSTGRES_USER=perfuser \
  -e POSTGRES_PASSWORD=perfpass \
  -p 5432:5432 \
  -d postgres:15
```

### Initialize Database
```bash
cd database
psql -h localhost -U perfuser -d rest_api_perf -f schema.sql
java -jar data-generator.jar
```

## Running Variants

Each variant runs on a different port:
- **Variant A (Jersey)**: http://localhost:8081
- **Variant C (Spring)**: http://localhost:8082
- **Variant D (Spring Data)**: http://localhost:8083

### Start a variant
```bash
# Variant A
cd variant-a-jersey
mvn spring-boot:run

# Variant C
cd variant-c-spring
mvn spring-boot:run

# Variant D
cd variant-d-spring-data
mvn spring-boot:run
```

## Monitoring

### Prometheus
```bash
cd monitoring
docker-compose up -d prometheus
```
Access: http://localhost:9090

### Grafana
```bash
docker-compose up -d grafana
```
Access: http://localhost:3000 (admin/admin)

## JMeter Tests

### Scenario 1: READ Heavy
```bash
jmeter -n -t jmeter/scenario1-read-heavy.jmx -l results/s1-variant-a.jtl
```

### Scenario 2: JOIN Filter
```bash
jmeter -n -t jmeter/scenario2-join-filter.jmx -l results/s2-variant-a.jtl
```

### Scenario 3: Mixed Operations
```bash
jmeter -n -t jmeter/scenario3-mixed.jmx -l results/s3-variant-a.jtl
```

### Scenario 4: Heavy Body
```bash
jmeter -n -t jmeter/scenario4-heavy-body.jmx -l results/s4-variant-a.jtl
```

## Common Configuration

All variants use:
- **HikariCP** connection pool (max 20 connections)
- **No L2 Hibernate cache**
- **Same pagination** (default size=50, max=100)
- **Same JSON payloads**
- **Same database** (PostgreSQL)

## API Endpoints

### Categories
- `GET /categories?page={page}&size={size}` - List categories
- `GET /categories/{id}` - Get category by ID
- `GET /categories/{id}/items?page={page}&size={size}` - Get items by category
- `POST /categories` - Create category
- `PUT /categories/{id}` - Update category
- `DELETE /categories/{id}` - Delete category

### Items
- `GET /items?page={page}&size={size}` - List items
- `GET /items/{id}` - Get item by ID
- `GET /items?categoryId={categoryId}&page={page}&size={size}` - Filter by category
- `POST /items` - Create item
- `PUT /items/{id}` - Update item
- `DELETE /items/{id}` - Delete item

## Performance Metrics

Measured for each variant:
- **RPS** (Requests Per Second)
- **Latency**: p50, p95, p99
- **Error Rate** (%)
- **CPU Usage** (%)
- **RAM Usage** (MB)
- **GC Metrics** (count, time)
- **Thread Count**

## Results

See `results/ANALYSIS.md` for detailed comparison and conclusions.
