# 🧪 Commandes de Test Rapides

Collection de commandes prêtes à l'emploi pour tester les API.

## Démarrage

```bash
# Jersey
docker-compose --profile jersey --profile monitoring up -d

# Spring
docker-compose --profile spring --profile monitoring up -d

# Spring Data
docker-compose --profile springdata --profile monitoring up -d
```

## Tests API - Jersey (Port 8081)

### Health Check
```bash
curl http://localhost:8081/actuator/health
```

### GET - Liste des items
```bash
curl http://localhost:8081/items?page=0&size=10
```

### GET - Item par ID
```bash
curl http://localhost:8081/items/1
```

### GET - Items par catégorie
```bash
curl http://localhost:8081/items?categoryId=1&page=0&size=10
```

### GET - Liste des catégories
```bash
curl http://localhost:8081/categories?page=0&size=10
```

### GET - Catégorie par ID
```bash
curl http://localhost:8081/categories/1
```

### GET - Items d'une catégorie
```bash
curl http://localhost:8081/categories/1/items?page=0&size=10
```

### POST - Créer un item
```bash
curl -X POST http://localhost:8081/items \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test Item\",\"description\":\"Description test\",\"price\":99.99,\"quantity\":10,\"categoryId\":1}"
```

### PUT - Modifier un item
```bash
curl -X PUT http://localhost:8081/items/1 \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Updated Item\",\"description\":\"Updated description\",\"price\":149.99,\"quantity\":20,\"categoryId\":1}"
```

### DELETE - Supprimer un item
```bash
curl -X DELETE http://localhost:8081/items/100000
```

### POST - Créer une catégorie
```bash
curl -X POST http://localhost:8081/categories \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"New Category\",\"description\":\"Test category\"}"
```

## Tests API - Spring (Port 8082)

Remplacer `8081` par `8082` dans toutes les commandes ci-dessus.

```bash
curl http://localhost:8082/items?page=0&size=10
curl http://localhost:8082/categories?page=0&size=10
```

## Tests API - Spring Data (Port 8083)

Remplacer `8081` par `8083` dans toutes les commandes ci-dessus.

```bash
curl http://localhost:8083/items?page=0&size=10
curl http://localhost:8083/categories?page=0&size=10
```

## Tests JMeter

### Générer les plans de test
```bash
cd jmeter
python generate-jmx.py
```

### Scenario 1: READ Heavy
```bash
# Jersey
jmeter -n -t jmeter/scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l results/s1-jersey.jtl -e -o results/s1-jersey-report

# Spring
jmeter -n -t jmeter/scenario1-read-heavy.jmx -Jhost=localhost -Jport=8082 -l results/s1-spring.jtl -e -o results/s1-spring-report

# Spring Data
jmeter -n -t jmeter/scenario1-read-heavy.jmx -Jhost=localhost -Jport=8083 -l results/s1-springdata.jtl -e -o results/s1-springdata-report
```

### Scenario 2: JOIN Filter
```bash
# Jersey
jmeter -n -t jmeter/scenario2-join-filter.jmx -Jhost=localhost -Jport=8081 -l results/s2-jersey.jtl -e -o results/s2-jersey-report

# Spring
jmeter -n -t jmeter/scenario2-join-filter.jmx -Jhost=localhost -Jport=8082 -l results/s2-spring.jtl -e -o results/s2-spring-report

# Spring Data
jmeter -n -t jmeter/scenario2-join-filter.jmx -Jhost=localhost -Jport=8083 -l results/s2-springdata.jtl -e -o results/s2-springdata-report
```

### Scenario 3: Mixed Operations
```bash
# Jersey
jmeter -n -t jmeter/scenario3-mixed.jmx -Jhost=localhost -Jport=8081 -l results/s3-jersey.jtl -e -o results/s3-jersey-report

# Spring
jmeter -n -t jmeter/scenario3-mixed.jmx -Jhost=localhost -Jport=8082 -l results/s3-spring.jtl -e -o results/s3-spring-report

# Spring Data
jmeter -n -t jmeter/scenario3-mixed.jmx -Jhost=localhost -Jport=8083 -l results/s3-springdata.jtl -e -o results/s3-springdata-report
```

### Scenario 4: Heavy Body
```bash
# Jersey
jmeter -n -t jmeter/scenario4-heavy-body.jmx -Jhost=localhost -Jport=8081 -l results/s4-jersey.jtl -e -o results/s4-jersey-report

# Spring
jmeter -n -t jmeter/scenario4-heavy-body.jmx -Jhost=localhost -Jport=8082 -l results/s4-spring.jtl -e -o results/s4-spring-report

# Spring Data
jmeter -n -t jmeter/scenario4-heavy-body.jmx -Jhost=localhost -Jport=8083 -l results/s4-springdata.jtl -e -o results/s4-springdata-report
```

## Monitoring

### Prometheus
```bash
# Ouvrir dans le navigateur
start http://localhost:9090

# Requêtes utiles
# RPS: rate(http_server_requests_seconds_count[1m])
# p99: histogram_quantile(0.99, rate(http_server_requests_seconds_bucket[1m]))
# CPU: process_cpu_usage
# Memory: jvm_memory_used_bytes{area="heap"} / 1024 / 1024
```

### Grafana
```bash
# Ouvrir dans le navigateur
start http://localhost:3000

# Login: admin / admin
# Importer dashboard ID: 4701
```

## Base de Données

### Connexion
```bash
# Depuis l'hôte
psql -h localhost -p 5432 -U perfuser -d rest_api_perf

# Depuis Docker
docker exec -it rest-api-postgres psql -U perfuser -d rest_api_perf
```

### Requêtes SQL
```sql
-- Compter les catégories
SELECT COUNT(*) FROM category;

-- Compter les items
SELECT COUNT(*) FROM item;

-- Items par catégorie
SELECT category_id, COUNT(*) as item_count 
FROM item 
GROUP BY category_id 
ORDER BY item_count DESC 
LIMIT 10;

-- Catégories avec le plus d'items
SELECT c.id, c.name, COUNT(i.id) as item_count
FROM category c
LEFT JOIN item i ON c.id = i.category_id
GROUP BY c.id, c.name
ORDER BY item_count DESC
LIMIT 10;

-- Prix moyen par catégorie
SELECT c.name, AVG(i.price) as avg_price, COUNT(i.id) as item_count
FROM category c
LEFT JOIN item i ON c.id = i.category_id
GROUP BY c.id, c.name
ORDER BY avg_price DESC
LIMIT 10;
```

## Docker

### Logs
```bash
# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f variant-a-jersey
docker-compose logs -f postgres
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

### Statut
```bash
docker-compose ps
docker stats
```

### Redémarrage
```bash
# Un service
docker-compose restart variant-a-jersey

# Tous
docker-compose restart
```

### Arrêt
```bash
# Arrêter
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v
```

### Rebuild
```bash
# Un variant
docker-compose build variant-a-jersey

# Tous
docker-compose build

# Rebuild et redémarrer
docker-compose up -d --build
```

## PowerShell (Windows)

### Tester tous les variants automatiquement
```powershell
# Créer test-all.ps1
$variants = @(
    @{Name="jersey"; Port=8081},
    @{Name="spring"; Port=8082},
    @{Name="springdata"; Port=8083}
)

foreach ($v in $variants) {
    Write-Host "Testing $($v.Name)..." -ForegroundColor Green
    
    # Test health
    $health = Invoke-RestMethod "http://localhost:$($v.Port)/actuator/health"
    Write-Host "  Health: $($health.status)" -ForegroundColor $(if($health.status -eq "UP"){"Green"}else{"Red"})
    
    # Test items
    $items = Invoke-RestMethod "http://localhost:$($v.Port)/items?page=0&size=5"
    Write-Host "  Items returned: $($items.content.Count)" -ForegroundColor Cyan
    Write-Host "  Total items: $($items.totalElements)" -ForegroundColor Cyan
}
```

### Exécuter
```powershell
.\test-all.ps1
```

## Batch Script (Windows)

### test-api.bat
```batch
@echo off
echo Testing Jersey API...
curl http://localhost:8081/items?page=0^&size=10
echo.
echo.
echo Testing Spring API...
curl http://localhost:8082/items?page=0^&size=10
echo.
echo.
echo Testing Spring Data API...
curl http://localhost:8083/items?page=0^&size=10
pause
```

## Vérifications Rapides

### Tous les services sont-ils UP ?
```bash
docker-compose ps | grep "Up"
```

### Les ports sont-ils ouverts ?
```bash
# Windows
netstat -ano | findstr "8081 8082 8083 9090 3000 5432"

# PowerShell
Test-NetConnection -ComputerName localhost -Port 8081
Test-NetConnection -ComputerName localhost -Port 8082
Test-NetConnection -ComputerName localhost -Port 8083
```

### Les métriques sont-elles disponibles ?
```bash
curl http://localhost:8081/actuator/prometheus | head -20
curl http://localhost:8082/actuator/prometheus | head -20
curl http://localhost:8083/actuator/prometheus | head -20
```

## Nettoyage

### Supprimer les résultats de tests
```bash
rm -rf results/*.jtl
rm -rf results/*-report
```

### Réinitialiser la base de données
```bash
docker-compose down -v
docker-compose up -d postgres
# Attendre 2 minutes pour la génération des données
```

### Nettoyer Docker complètement
```bash
docker-compose down -v
docker system prune -a
```

## Raccourcis Utiles

```bash
# Alias à ajouter dans votre profil PowerShell
function Start-Jersey { docker-compose --profile jersey --profile monitoring up -d }
function Start-Spring { docker-compose --profile spring --profile monitoring up -d }
function Start-SpringData { docker-compose --profile springdata --profile monitoring up -d }
function Stop-All { docker-compose down }
function Show-Logs { docker-compose logs -f }
function Show-Status { docker-compose ps }

# Utilisation
Start-Jersey
Show-Status
Show-Logs
Stop-All
```

---

**Copier-coller et tester ! 🚀**
