# Guide Docker - REST API Performance Testing

Ce guide explique comment lancer tout le projet avec Docker.

## Prérequis

- Docker Desktop installé et en cours d'exécution
- Au moins 4 GB de RAM disponible pour Docker
- Ports disponibles : 5432, 8081, 8082, 8083, 9090, 3000

## Architecture Docker

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Network                        │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Jersey   │  │  Spring  │  │  Spring  │             │
│  │  :8081   │  │  :8082   │  │  Data    │             │
│  └────┬─────┘  └────┬─────┘  │  :8083   │             │
│       │             │         └────┬─────┘             │
│       │             │              │                    │
│       └─────────────┴──────────────┘                    │
│                     │                                    │
│              ┌──────▼──────┐                            │
│              │  PostgreSQL │                            │
│              │    :5432    │                            │
│              └─────────────┘                            │
│                                                          │
│  ┌────────────┐         ┌──────────┐                   │
│  │ Prometheus │◄────────┤ Grafana  │                   │
│  │   :9090    │         │  :3000   │                   │
│  └────────────┘         └──────────┘                   │
└─────────────────────────────────────────────────────────┘
```

## Commandes Rapides

### 1. Démarrer la base de données uniquement

```bash
docker-compose up -d postgres
```

Attendre que la base soit prête (création des données ~1-2 minutes) :
```bash
docker-compose logs -f postgres
```

### 2. Démarrer un variant spécifique

**Variant A - Jersey (JAX-RS)** :
```bash
docker-compose --profile jersey up -d
```

**Variant C - Spring @RestController** :
```bash
docker-compose --profile spring up -d
```

**Variant D - Spring Data REST** :
```bash
docker-compose --profile springdata up -d
```

### 3. Démarrer avec monitoring

**Jersey + Monitoring** :
```bash
docker-compose --profile jersey --profile monitoring up -d
```

**Spring + Monitoring** :
```bash
docker-compose --profile spring --profile monitoring up -d
```

**Spring Data + Monitoring** :
```bash
docker-compose --profile springdata --profile monitoring up -d
```

### 4. Démarrer TOUT (tous les variants + monitoring)

```bash
docker-compose --profile all up -d
```

⚠️ **Attention** : Cela démarre les 3 variants en même temps. Utilisez ceci uniquement pour vérifier que tout fonctionne, pas pour les tests de performance.

## Vérification du Démarrage

### Vérifier les logs

```bash
# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f variant-a-jersey
docker-compose logs -f postgres
```

### Vérifier la santé des services

```bash
docker-compose ps
```

Tous les services doivent afficher "healthy" ou "running".

### Tester les endpoints

**Jersey (8081)** :
```bash
curl http://localhost:8081/actuator/health
curl http://localhost:8081/items?page=0&size=10
curl http://localhost:8081/categories?page=0&size=10
```

**Spring (8082)** :
```bash
curl http://localhost:8082/actuator/health
curl http://localhost:8082/items?page=0&size=10
```

**Spring Data (8083)** :
```bash
curl http://localhost:8083/actuator/health
curl http://localhost:8083/items?page=0&size=10
```

### Accéder aux interfaces web

- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3000 (admin/admin)

## Workflow de Test

### Scénario 1 : Tester Jersey

```bash
# 1. Démarrer Jersey + Monitoring
docker-compose --profile jersey --profile monitoring up -d

# 2. Attendre 30 secondes pour le warmup
timeout 30

# 3. Vérifier que tout est OK
curl http://localhost:8081/actuator/health

# 4. Lancer les tests JMeter (depuis votre machine hôte)
cd jmeter
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l ../results/s1-jersey.jtl

# 5. Arrêter Jersey
docker-compose --profile jersey down
```

### Scénario 2 : Tester Spring

```bash
# 1. Démarrer Spring + Monitoring
docker-compose --profile spring --profile monitoring up -d

# 2. Attendre et tester
timeout 30
curl http://localhost:8082/actuator/health

# 3. Lancer les tests JMeter
cd jmeter
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8082 -l ../results/s1-spring.jtl

# 4. Arrêter
docker-compose --profile spring down
```

### Scénario 3 : Tester Spring Data

```bash
# 1. Démarrer Spring Data + Monitoring
docker-compose --profile springdata --profile monitoring up -d

# 2. Attendre et tester
timeout 30
curl http://localhost:8083/actuator/health

# 3. Lancer les tests JMeter
cd jmeter
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8083 -l ../results/s1-springdata.jtl

# 4. Arrêter
docker-compose --profile springdata down
```

## Commandes de Gestion

### Voir les logs en temps réel

```bash
docker-compose logs -f variant-a-jersey
```

### Redémarrer un service

```bash
docker-compose restart variant-a-jersey
```

### Arrêter tous les services

```bash
docker-compose down
```

### Arrêter et supprimer les volumes (réinitialisation complète)

```bash
docker-compose down -v
```

⚠️ Cela supprimera toutes les données de la base !

### Reconstruire les images

Si vous modifiez le code :

```bash
docker-compose build variant-a-jersey
docker-compose build variant-c-spring
docker-compose build variant-d-spring-data
```

Ou tout reconstruire :

```bash
docker-compose build
```

## Accès à la Base de Données

### Depuis l'hôte

```bash
psql -h localhost -p 5432 -U perfuser -d rest_api_perf
# Password: perfpass
```

### Depuis un conteneur

```bash
docker exec -it rest-api-postgres psql -U perfuser -d rest_api_perf
```

### Vérifier les données

```sql
SELECT COUNT(*) FROM category;  -- Devrait retourner 2000
SELECT COUNT(*) FROM item;      -- Devrait retourner 100000
```

## Monitoring avec Grafana

1. Ouvrir http://localhost:3000
2. Login : admin/admin
3. Aller dans "Dashboards"
4. Importer un dashboard JVM :
   - Cliquer sur "+" → "Import"
   - Entrer l'ID : **4701** (JVM Micrometer)
   - Sélectionner "Prometheus" comme data source
   - Cliquer "Import"

5. Pendant les tests, vous verrez :
   - CPU usage
   - Memory (Heap/Non-Heap)
   - GC activity
   - Thread count
   - HTTP request metrics

## Troubleshooting

### Le conteneur ne démarre pas

```bash
# Voir les logs d'erreur
docker-compose logs variant-a-jersey

# Vérifier que PostgreSQL est prêt
docker-compose logs postgres | grep "ready to accept connections"
```

### La base de données n'a pas de données

```bash
# Vérifier les logs d'initialisation
docker-compose logs postgres

# Réinitialiser la base
docker-compose down -v
docker-compose up -d postgres
```

### Port déjà utilisé

```bash
# Windows - Trouver le processus
netstat -ano | findstr :8081

# Tuer le processus
taskkill /PID <PID> /F
```

### Problème de mémoire Docker

Augmenter la mémoire allouée à Docker Desktop :
- Docker Desktop → Settings → Resources → Memory
- Recommandé : Au moins 4 GB

### Les métriques n'apparaissent pas dans Prometheus

1. Vérifier que le variant est démarré :
   ```bash
   curl http://localhost:8081/actuator/prometheus
   ```

2. Vérifier les targets dans Prometheus :
   - http://localhost:9090/targets
   - Les targets doivent être "UP"

3. Vérifier le réseau Docker :
   ```bash
   docker network inspect rest-controller-api_perf-network
   ```

## Nettoyage Complet

Pour tout supprimer et recommencer :

```bash
# Arrêter tous les conteneurs
docker-compose down -v

# Supprimer les images construites
docker rmi rest-controller-api-variant-a-jersey
docker rmi rest-controller-api-variant-c-spring
docker rmi rest-controller-api-variant-d-spring-data

# Nettoyer Docker
docker system prune -a
```

## Performance Tips

1. **Un seul variant à la fois** : Pour les tests de performance, ne lancez qu'un seul variant
2. **Warmup** : Attendez toujours 30-60 secondes après le démarrage
3. **Monitoring** : Gardez Grafana ouvert pendant les tests
4. **Logs** : Surveillez les logs pour détecter les erreurs
5. **Ressources** : Assurez-vous que Docker a assez de RAM (4GB minimum)

## Commandes Utiles

```bash
# Voir l'utilisation des ressources
docker stats

# Inspecter un conteneur
docker inspect variant-a-jersey

# Exécuter une commande dans un conteneur
docker exec -it variant-a-jersey sh

# Copier des fichiers depuis/vers un conteneur
docker cp variant-a-jersey:/app/logs ./logs

# Voir les réseaux Docker
docker network ls

# Voir les volumes
docker volume ls
```

## Script PowerShell Automatisé

Créez `test-docker.ps1` :

```powershell
# Test automatisé avec Docker

$variants = @(
    @{Name="jersey"; Port=8081; Profile="jersey"},
    @{Name="spring"; Port=8082; Profile="spring"},
    @{Name="springdata"; Port=8083; Profile="springdata"}
)

foreach ($variant in $variants) {
    Write-Host "Testing $($variant.Name)..." -ForegroundColor Green
    
    # Start variant with monitoring
    docker-compose --profile $($variant.Profile) --profile monitoring up -d
    
    # Wait for warmup
    Start-Sleep -Seconds 45
    
    # Health check
    $health = Invoke-RestMethod "http://localhost:$($variant.Port)/actuator/health"
    if ($health.status -ne "UP") {
        Write-Host "Service not healthy!" -ForegroundColor Red
        continue
    }
    
    # Run tests
    cd jmeter
    jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=$($variant.Port) `
           -l ../results/s1-$($variant.Name).jtl
    cd ..
    
    # Stop variant
    docker-compose --profile $($variant.Profile) down
    
    Start-Sleep -Seconds 30
}

Write-Host "All tests completed!" -ForegroundColor Green
```

---

**Prêt à démarrer !** 🚀

Commencez par :
```bash
docker-compose --profile jersey --profile monitoring up -d
```

Puis ouvrez http://localhost:3000 pour Grafana et http://localhost:8081/items?page=0&size=10 pour tester l'API.
