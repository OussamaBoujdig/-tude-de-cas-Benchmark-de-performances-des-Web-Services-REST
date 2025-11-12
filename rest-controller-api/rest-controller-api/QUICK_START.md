# 🚀 Quick Start Guide

Démarrage rapide du projet REST API Performance Testing avec Docker.

## Prérequis

✅ Docker Desktop installé et en cours d'exécution  
✅ 4 GB RAM minimum disponible pour Docker  
✅ Ports libres : 5432, 8081, 8082, 8083, 9090, 3000

## Démarrage en 3 Étapes

### 1️⃣ Lancer un Variant avec Monitoring

**Option A : Interface Graphique (Recommandé)**

Double-cliquez sur `docker-start.bat` et choisissez une option.

**Option B : Ligne de Commande**

```bash
# Jersey (Variant A)
docker-compose --profile jersey --profile monitoring up -d

# OU Spring (Variant C)
docker-compose --profile spring --profile monitoring up -d

# OU Spring Data (Variant D)
docker-compose --profile springdata --profile monitoring up -d
```

### 2️⃣ Attendre le Démarrage (30-60 secondes)

Vérifier les logs :
```bash
docker-compose logs -f
```

Ou vérifier le statut :
```bash
docker-compose ps
```

### 3️⃣ Tester l'API

**Jersey (Port 8081)** :
```bash
curl http://localhost:8081/items?page=0&size=10
curl http://localhost:8081/actuator/health
```

**Spring (Port 8082)** :
```bash
curl http://localhost:8082/items?page=0&size=10
```

**Spring Data (Port 8083)** :
```bash
curl http://localhost:8083/items?page=0&size=10
```

## Accès aux Interfaces

| Service | URL | Credentials |
|---------|-----|-------------|
| **API Jersey** | http://localhost:8081 | - |
| **API Spring** | http://localhost:8082 | - |
| **API Spring Data** | http://localhost:8083 | - |
| **Prometheus** | http://localhost:9090 | - |
| **Grafana** | http://localhost:3000 | admin/admin |
| **PostgreSQL** | localhost:5432 | perfuser/perfpass |

## Endpoints Disponibles

### Categories
- `GET /categories?page=0&size=50` - Liste des catégories
- `GET /categories/{id}` - Catégorie par ID
- `GET /categories/{id}/items` - Items d'une catégorie
- `POST /categories` - Créer une catégorie
- `PUT /categories/{id}` - Modifier une catégorie
- `DELETE /categories/{id}` - Supprimer une catégorie

### Items
- `GET /items?page=0&size=50` - Liste des items
- `GET /items/{id}` - Item par ID
- `GET /items?categoryId=1&page=0&size=50` - Items par catégorie
- `POST /items` - Créer un item
- `PUT /items/{id}` - Modifier un item
- `DELETE /items/{id}` - Supprimer un item

## Exemples de Requêtes

### GET - Récupérer des items
```bash
curl http://localhost:8081/items?page=0&size=10
```

### POST - Créer un item
```bash
curl -X POST http://localhost:8081/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Item",
    "description": "Description test",
    "price": 99.99,
    "quantity": 10,
    "categoryId": 1
  }'
```

### PUT - Modifier un item
```bash
curl -X PUT http://localhost:8081/items/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Item",
    "description": "Updated description",
    "price": 149.99,
    "quantity": 20,
    "categoryId": 1
  }'
```

### DELETE - Supprimer un item
```bash
curl -X DELETE http://localhost:8081/items/1
```

## Données de Test

La base de données est automatiquement initialisée avec :
- **2,000 catégories**
- **100,000 items**

Vérifier les données :
```bash
docker exec -it rest-api-postgres psql -U perfuser -d rest_api_perf -c "SELECT COUNT(*) FROM category;"
docker exec -it rest-api-postgres psql -U perfuser -d rest_api_perf -c "SELECT COUNT(*) FROM item;"
```

## Lancer les Tests JMeter

### Prérequis
- JMeter installé
- Un variant en cours d'exécution

### Générer les plans de test
```bash
cd jmeter
python generate-jmx.py
```

### Exécuter un test
```bash
# Scenario 1: READ Heavy
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l ../results/s1-jersey.jtl

# Scenario 2: JOIN Filter
jmeter -n -t scenario2-join-filter.jmx -Jhost=localhost -Jport=8081 -l ../results/s2-jersey.jtl

# Scenario 3: Mixed Operations
jmeter -n -t scenario3-mixed.jmx -Jhost=localhost -Jport=8081 -l ../results/s3-jersey.jtl

# Scenario 4: Heavy Body
jmeter -n -t scenario4-heavy-body.jmx -Jhost=localhost -Jport=8081 -l ../results/s4-jersey.jtl
```

### Générer un rapport HTML
```bash
jmeter -g results/s1-jersey.jtl -o results/s1-jersey-report
```

## Monitoring avec Grafana

1. Ouvrir http://localhost:3000
2. Login : **admin** / **admin**
3. Importer un dashboard JVM :
   - Cliquer sur **+** → **Import**
   - Entrer l'ID : **4701**
   - Sélectionner **Prometheus** comme data source
   - Cliquer **Import**

4. Pendant les tests, observer :
   - CPU usage
   - Memory (Heap/Non-Heap)
   - GC activity
   - Thread count
   - HTTP metrics

## Commandes Utiles

### Voir les logs
```bash
# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f variant-a-jersey
docker-compose logs -f postgres
```

### Redémarrer un service
```bash
docker-compose restart variant-a-jersey
```

### Arrêter tout
```bash
docker-compose down
```

### Nettoyer complètement (supprime les données)
```bash
docker-compose down -v
```

### Reconstruire après modification du code
```bash
docker-compose build variant-a-jersey
docker-compose --profile jersey up -d
```

### Voir l'utilisation des ressources
```bash
docker stats
```

## Workflow de Test Complet

### 1. Tester Jersey
```bash
# Démarrer
docker-compose --profile jersey --profile monitoring up -d

# Attendre 30s
timeout 30

# Tester
curl http://localhost:8081/actuator/health

# Lancer JMeter
cd jmeter
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l ../results/s1-jersey.jtl

# Arrêter
docker-compose down
```

### 2. Tester Spring
```bash
# Démarrer
docker-compose --profile spring --profile monitoring up -d

# Attendre et tester
timeout 30
curl http://localhost:8082/actuator/health

# Lancer JMeter
cd jmeter
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8082 -l ../results/s1-spring.jtl

# Arrêter
docker-compose down
```

### 3. Tester Spring Data
```bash
# Démarrer
docker-compose --profile springdata --profile monitoring up -d

# Attendre et tester
timeout 30
curl http://localhost:8083/actuator/health

# Lancer JMeter
cd jmeter
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8083 -l ../results/s1-springdata.jtl

# Arrêter
docker-compose down
```

## Troubleshooting

### Le service ne démarre pas
```bash
# Voir les logs d'erreur
docker-compose logs variant-a-jersey

# Vérifier PostgreSQL
docker-compose logs postgres
```

### Port déjà utilisé
```bash
# Windows
netstat -ano | findstr :8081
taskkill /PID <PID> /F
```

### Pas de données dans la base
```bash
# Réinitialiser
docker-compose down -v
docker-compose up -d postgres
# Attendre 2 minutes pour l'initialisation
```

### Métriques absentes dans Prometheus
1. Vérifier : http://localhost:8081/actuator/prometheus
2. Vérifier targets : http://localhost:9090/targets
3. Redémarrer : `docker-compose restart prometheus`

## Structure du Projet

```
rest-controller-api/
├── common/                    # Modèles partagés
├── variant-a-jersey/          # Jersey (JAX-RS)
├── variant-c-spring/          # Spring @RestController
├── variant-d-spring-data/     # Spring Data REST
├── database/                  # Scripts SQL
├── monitoring/                # Prometheus, Grafana
├── jmeter/                    # Plans de test
├── results/                   # Résultats des tests
├── docker-compose.yml         # Configuration Docker
├── docker-start.bat           # Script de démarrage
└── DOCKER_GUIDE.md           # Guide complet
```

## Prochaines Étapes

1. ✅ Démarrer un variant
2. ✅ Tester l'API avec curl
3. ✅ Ouvrir Grafana
4. ✅ Générer les plans JMeter
5. ✅ Lancer les tests de performance
6. ✅ Remplir `results/MEASUREMENTS.md`
7. ✅ Analyser les résultats dans `results/ANALYSIS.md`

## Support

- **Guide Docker complet** : `DOCKER_GUIDE.md`
- **Guide de setup** : `SETUP_GUIDE.md`
- **README principal** : `README.md`
- **Analyse des résultats** : `results/ANALYSIS.md`

---

**Bon test ! 🚀**

Pour démarrer maintenant :
```bash
docker-compose --profile jersey --profile monitoring up -d
```

Puis ouvrez : http://localhost:8081/items?page=0&size=10
