# 📊 REST API Performance Comparison - Résumé du Projet

## Vue d'Ensemble

Ce projet implémente et compare **3 approches différentes** pour créer des API REST en Java :

1. **Variant A** : Jersey (JAX-RS) - Port 8081
2. **Variant C** : Spring Boot @RestController - Port 8082
3. **Variant D** : Spring Boot Spring Data REST - Port 8083

## Objectif

Mesurer et comparer les performances de chaque approche sur :
- **Throughput** (RPS - Requests Per Second)
- **Latency** (p50, p95, p99)
- **Resource Usage** (CPU, RAM, GC)
- **Error Rate**

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Load Testing                          │
│                   (Apache JMeter)                        │
│                                                          │
│  Scenario 1: READ Heavy                                 │
│  Scenario 2: JOIN Filter                                │
│  Scenario 3: Mixed Operations                           │
│  Scenario 4: Heavy Body                                 │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│                   REST API Variants                      │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Jersey   │  │  Spring  │  │  Spring  │             │
│  │  :8081   │  │  :8082   │  │  Data    │             │
│  │          │  │          │  │  :8083   │             │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘             │
│       │             │              │                    │
│       └─────────────┴──────────────┘                    │
│                     │                                    │
│              ┌──────▼──────┐                            │
│              │  PostgreSQL │                            │
│              │  2K cats    │                            │
│              │  100K items │                            │
│              └─────────────┘                            │
└─────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│                    Monitoring                            │
│                                                          │
│  ┌────────────┐         ┌──────────┐                   │
│  │ Prometheus │◄────────┤ Grafana  │                   │
│  │   :9090    │         │  :3000   │                   │
│  │            │         │          │                   │
│  │  Metrics   │         │Dashboard │                   │
│  └────────────┘         └──────────┘                   │
└─────────────────────────────────────────────────────────┘
```

## Données de Test

- **2,000 catégories**
- **100,000 items**
- Distribution aléatoire des items dans les catégories
- Génération automatique au démarrage de PostgreSQL

## Configuration Identique

Tous les variants utilisent :
- ✅ **Même base de données** PostgreSQL
- ✅ **HikariCP** (max 20 connexions)
- ✅ **Pas de L2 cache** Hibernate
- ✅ **Même pagination** (default=50, max=100)
- ✅ **Même JSON** (Jackson)
- ✅ **Même JVM** (Java 21)

## Endpoints Implémentés

### Categories
| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/categories?page=&size=` | Liste paginée |
| GET | `/categories/{id}` | Par ID |
| GET | `/categories/{id}/items` | Items d'une catégorie |
| POST | `/categories` | Créer |
| PUT | `/categories/{id}` | Modifier |
| DELETE | `/categories/{id}` | Supprimer |

### Items
| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/items?page=&size=` | Liste paginée |
| GET | `/items/{id}` | Par ID |
| GET | `/items?categoryId=&page=&size=` | Filtrer par catégorie |
| POST | `/items` | Créer |
| PUT | `/items/{id}` | Modifier |
| DELETE | `/items/{id}` | Supprimer |

## Scénarios de Test JMeter

### Scenario 1: READ Heavy
- **50%** GET /items?page=&size=50
- **20%** GET /items?categoryId=
- **20%** GET /categories/{id}/items
- **10%** GET /categories
- **Load**: 50→100→200 threads, 10 min

### Scenario 2: JOIN Filter
- **70%** GET /items?categoryId=
- **30%** GET /items/{id}
- **Load**: 60→120 threads, 10 min

### Scenario 3: Mixed Operations
- **60%** GET
- **20%** POST (1 KB payload)
- **15%** PUT (1 KB payload)
- **5%** DELETE
- **Load**: 50→100 threads, 10 min

### Scenario 4: Heavy Body
- **50%** POST (5 KB payload)
- **30%** PUT (5 KB payload)
- **20%** GET
- **Load**: 30→60 threads, 10 min

## Métriques Collectées

### Performance
- **RPS** (Requests Per Second)
- **Latency** : p50, p95, p99
- **Error Rate** (%)

### Resources (JVM)
- **CPU Usage** (%)
- **Memory** (Heap MB)
- **GC Count** (total)
- **GC Time** (ms)
- **Thread Count**

## Structure du Projet

```
rest-controller-api/
│
├── common/                           # Module partagé
│   ├── src/main/java/.../model/
│   │   ├── Category.java
│   │   └── Item.java
│   └── pom.xml
│
├── variant-a-jersey/                 # Jersey (JAX-RS)
│   ├── src/main/java/.../jersey/
│   │   ├── JerseyApplication.java
│   │   ├── config/JerseyConfig.java
│   │   ├── repository/
│   │   └── resource/
│   ├── Dockerfile
│   └── pom.xml
│
├── variant-c-spring/                 # Spring @RestController
│   ├── src/main/java/.../spring/
│   │   ├── SpringApplication.java
│   │   ├── repository/
│   │   └── controller/
│   ├── Dockerfile
│   └── pom.xml
│
├── variant-d-spring-data/            # Spring Data REST
│   ├── src/main/java/.../springdata/
│   │   ├── SpringDataApplication.java
│   │   ├── repository/
│   │   └── controller/
│   ├── Dockerfile
│   └── pom.xml
│
├── database/                          # Base de données
│   ├── schema.sql                    # Schéma DDL
│   ├── generate-data.sql             # Génération SQL
│   ├── src/main/java/
│   │   └── DataGenerator.java       # Génération Java
│   └── pom.xml
│
├── monitoring/                        # Monitoring
│   ├── prometheus.yml                # Config Prometheus
│   ├── grafana-datasources.yml       # Config Grafana
│   ├── jmx-exporter-config.yml       # JMX metrics
│   └── docker-compose.yml            # Stack monitoring
│
├── jmeter/                            # Tests de charge
│   ├── generate-jmx.py               # Générateur de plans
│   ├── scenario1-read-heavy.jmx
│   ├── scenario2-join-filter.jmx
│   ├── scenario3-mixed.jmx
│   ├── scenario4-heavy-body.jmx
│   └── README.md
│
├── results/                           # Résultats
│   ├── MEASUREMENTS.md               # Tables de mesures
│   └── ANALYSIS.md                   # Analyse et conclusions
│
├── docker-compose.yml                 # Orchestration Docker
├── docker-start.bat                   # Script Windows
├── docker-run.ps1                     # Script PowerShell
├── run-tests.bat                      # Tests automatisés
│
├── README.md                          # Documentation principale
├── SETUP_GUIDE.md                     # Guide de setup
├── DOCKER_GUIDE.md                    # Guide Docker
├── QUICK_START.md                     # Démarrage rapide
└── PROJECT_SUMMARY.md                 # Ce fichier
```

## Fichiers Importants

### Documentation
- 📘 **README.md** - Vue d'ensemble du projet
- 🚀 **QUICK_START.md** - Démarrage rapide (recommandé)
- 🐳 **DOCKER_GUIDE.md** - Guide Docker complet
- 🔧 **SETUP_GUIDE.md** - Installation détaillée

### Configuration
- 🐳 **docker-compose.yml** - Orchestration des services
- 📊 **monitoring/prometheus.yml** - Métriques
- 🗄️ **database/schema.sql** - Schéma de base

### Tests
- 📈 **jmeter/generate-jmx.py** - Génération des tests
- 🎯 **jmeter/scenario*.jmx** - Plans de test

### Résultats
- 📊 **results/MEASUREMENTS.md** - Tables à remplir
- 📝 **results/ANALYSIS.md** - Analyse comparative

## Démarrage Rapide

### Avec Docker (Recommandé)

```bash
# Option 1: Script Windows
docker-start.bat

# Option 2: Ligne de commande
docker-compose --profile jersey --profile monitoring up -d

# Option 3: PowerShell
.\docker-run.ps1 -Action jersey
```

### Sans Docker

```bash
# 1. Base de données
cd database
psql -h localhost -U perfuser -d rest_api_perf -f schema.sql
psql -h localhost -U perfuser -d rest_api_perf -f generate-data.sql

# 2. Build common
cd ../common
mvn clean install

# 3. Lancer un variant
cd ../variant-a-jersey
mvn spring-boot:run
```

## Workflow de Test

1. **Démarrer un variant** avec monitoring
2. **Attendre 30-60s** pour le warmup
3. **Générer les plans JMeter** : `python jmeter/generate-jmx.py`
4. **Lancer les tests** : `jmeter -n -t scenario1-read-heavy.jmx ...`
5. **Observer Grafana** : http://localhost:3000
6. **Collecter les métriques** dans `results/MEASUREMENTS.md`
7. **Répéter** pour les autres variants
8. **Analyser** les résultats dans `results/ANALYSIS.md`

## URLs Importantes

| Service | URL | Credentials |
|---------|-----|-------------|
| Jersey API | http://localhost:8081 | - |
| Spring API | http://localhost:8082 | - |
| Spring Data API | http://localhost:8083 | - |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3000 | admin/admin |
| PostgreSQL | localhost:5432 | perfuser/perfpass |

## Résultats Attendus

### Performance (Ordre attendu)

1. **Jersey** 🥇
   - Meilleur throughput
   - Latence la plus faible
   - Moins de ressources

2. **Spring @RestController** 🥈
   - Bon équilibre
   - Performance proche de Jersey
   - Meilleure productivité

3. **Spring Data REST** 🥉
   - Plus de latence (HATEOAS)
   - Plus de ressources
   - Développement le plus rapide

### Recommandations

- **Performance critique** → Jersey
- **Production standard** → Spring @RestController
- **Prototypage rapide** → Spring Data REST

## Technologies Utilisées

### Backend
- Java 21
- Jersey 3.1.5 (JAX-RS)
- Spring Boot 3.3.0
- Spring Data REST
- Hibernate 6.x
- PostgreSQL 15

### Monitoring
- Prometheus
- Grafana
- Micrometer
- JMX Exporter

### Testing
- Apache JMeter 5.6+
- Python 3.8+ (génération)

### Infrastructure
- Docker & Docker Compose
- HikariCP
- Maven

## Commandes Essentielles

```bash
# Démarrer
docker-compose --profile jersey --profile monitoring up -d

# Voir les logs
docker-compose logs -f

# Statut
docker-compose ps

# Tester l'API
curl http://localhost:8081/items?page=0&size=10

# Lancer un test JMeter
jmeter -n -t jmeter/scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l results/test.jtl

# Arrêter
docker-compose down

# Nettoyer
docker-compose down -v
```

## Prochaines Étapes

1. ✅ Lire `QUICK_START.md`
2. ✅ Démarrer avec Docker
3. ✅ Tester les endpoints
4. ✅ Configurer Grafana
5. ✅ Générer les plans JMeter
6. ✅ Lancer les tests
7. ✅ Remplir `MEASUREMENTS.md`
8. ✅ Analyser dans `ANALYSIS.md`
9. ✅ Prendre une décision architecturale

## Support et Documentation

- **Questions générales** : Voir `README.md`
- **Installation** : Voir `SETUP_GUIDE.md`
- **Docker** : Voir `DOCKER_GUIDE.md`
- **Démarrage rapide** : Voir `QUICK_START.md`
- **Tests JMeter** : Voir `jmeter/README.md`

## Auteur et Licence

Projet de comparaison de performance REST API  
Créé pour l'analyse comparative de frameworks Java

---

**Prêt à commencer ?**

```bash
docker-compose --profile jersey --profile monitoring up -d
```

Puis ouvrez : http://localhost:8081/items?page=0&size=10 🚀
