# 👋 COMMENCEZ ICI !

Bienvenue dans le projet de comparaison de performance REST API.

## 🎯 Objectif

Comparer **3 approches** pour créer des API REST en Java :
- **Jersey (JAX-RS)** - Performance maximale
- **Spring @RestController** - Équilibre
- **Spring Data REST** - Développement rapide

## 🚀 Démarrage Ultra-Rapide (2 minutes)

### Étape 1: Lancer avec Docker

**Option A - Double-clic** (Recommandé) :
```
Double-cliquez sur: docker-start.bat
Choisissez l'option 1 (Jersey)
```

**Option B - Ligne de commande** :
```bash
docker-compose --profile jersey --profile monitoring up -d
```

### Étape 2: Attendre 1-2 minutes

Le système va :
- ✅ Démarrer PostgreSQL
- ✅ Créer 2,000 catégories + 100,000 items
- ✅ Lancer l'API Jersey
- ✅ Démarrer Prometheus + Grafana

### Étape 3: Tester !

Ouvrez dans votre navigateur :
```
http://localhost:8081/items?page=0&size=10
```

Vous devriez voir du JSON avec 10 items ! 🎉

## 📊 Interfaces Disponibles

| Interface | URL | Description |
|-----------|-----|-------------|
| **API Jersey** | http://localhost:8081 | API REST à tester |
| **Prometheus** | http://localhost:9090 | Métriques |
| **Grafana** | http://localhost:3000 | Dashboards (admin/admin) |

## 🧪 Tester l'API

### Avec le navigateur
```
http://localhost:8081/items?page=0&size=10
http://localhost:8081/categories?page=0&size=10
```

### Avec curl
```bash
curl http://localhost:8081/items?page=0&size=10
curl http://localhost:8081/categories?page=0&size=10
curl http://localhost:8081/actuator/health
```

### Avec PowerShell
```powershell
Invoke-RestMethod http://localhost:8081/items?page=0&size=10
```

## 📚 Documentation

Selon ce que vous voulez faire :

### Je veux juste tester rapidement
➡️ Lisez **`QUICK_START.md`**

### Je veux comprendre Docker
➡️ Lisez **`DOCKER_GUIDE.md`**

### Je veux lancer les tests de performance
➡️ Lisez **`TEST_COMMANDS.md`** puis **`jmeter/README.md`**

### Je veux tout comprendre
➡️ Lisez **`PROJECT_SUMMARY.md`** puis **`README.md`**

### Je veux voir les résultats
➡️ Lisez **`results/ANALYSIS.md`**

## 🎬 Workflow Complet

### 1. Démarrer Jersey
```bash
docker-compose --profile jersey --profile monitoring up -d
```

### 2. Vérifier que ça marche
```bash
curl http://localhost:8081/actuator/health
```

### 3. Ouvrir Grafana
```
http://localhost:3000
Login: admin / admin
```

### 4. Importer un dashboard JVM
- Cliquer sur **+** → **Import**
- Entrer l'ID : **4701**
- Sélectionner **Prometheus**
- Cliquer **Import**

### 5. Générer les tests JMeter
```bash
cd jmeter
python generate-jmx.py
```

### 6. Lancer un test
```bash
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l ../results/s1-jersey.jtl
```

### 7. Observer Grafana pendant le test
Vous verrez :
- CPU monter
- Mémoire augmenter
- GC s'activer
- Requêtes HTTP

### 8. Analyser les résultats
```bash
jmeter -g results/s1-jersey.jtl -o results/s1-jersey-report
```

Ouvrir `results/s1-jersey-report/index.html`

### 9. Répéter pour Spring et Spring Data
```bash
# Arrêter Jersey
docker-compose down

# Démarrer Spring
docker-compose --profile spring --profile monitoring up -d

# Tester...
```

### 10. Comparer les résultats
Remplir `results/MEASUREMENTS.md` et lire `results/ANALYSIS.md`

## 🛠️ Commandes Essentielles

```bash
# Démarrer
docker-compose --profile jersey --profile monitoring up -d

# Voir les logs
docker-compose logs -f

# Statut
docker-compose ps

# Arrêter
docker-compose down

# Nettoyer tout
docker-compose down -v
```

## ❓ Questions Fréquentes

### Combien de temps prend le premier démarrage ?
**2-3 minutes** pour télécharger les images et générer les données.

### Puis-je lancer les 3 variants en même temps ?
**Oui**, mais pas pour les tests de performance ! Un seul à la fois pour des mesures précises.

### Où sont les données ?
Dans **PostgreSQL** (Docker volume). 2,000 catégories + 100,000 items générés automatiquement.

### Comment voir les métriques ?
**Grafana** : http://localhost:3000 (admin/admin)  
**Prometheus** : http://localhost:9090

### Ça ne marche pas !
1. Vérifier Docker est lancé : `docker ps`
2. Voir les logs : `docker-compose logs -f`
3. Vérifier les ports : `netstat -ano | findstr "8081"`
4. Lire `DOCKER_GUIDE.md` section Troubleshooting

## 🎯 Objectifs du Projet

### Court Terme (Aujourd'hui)
- [x] ✅ Projet créé
- [x] ✅ Docker configuré
- [ ] ⏳ Services démarrés
- [ ] ⏳ API testée
- [ ] ⏳ Grafana configuré

### Moyen Terme (Cette semaine)
- [ ] ⏳ Tests JMeter lancés
- [ ] ⏳ Résultats collectés
- [ ] ⏳ Analyse complétée

### Long Terme (Décision)
- [ ] ⏳ Choix architectural fait
- [ ] ⏳ Documentation partagée
- [ ] ⏳ Implémentation en production

## 📁 Fichiers Importants

```
📘 START_HERE.md          ← VOUS ÊTES ICI
🚀 QUICK_START.md         ← Démarrage rapide
🐳 DOCKER_GUIDE.md        ← Guide Docker complet
📊 PROJECT_SUMMARY.md     ← Vue d'ensemble
🧪 TEST_COMMANDS.md       ← Commandes de test
📋 STATUS.md              ← État actuel
📝 results/ANALYSIS.md    ← Conclusions
```

## 🎉 Prêt à Commencer ?

### Action Immédiate

**Windows** :
```
Double-cliquez sur: docker-start.bat
```

**Ligne de commande** :
```bash
docker-compose --profile jersey --profile monitoring up -d
```

**Puis** :
```
Ouvrez: http://localhost:8081/items?page=0&size=10
```

## 💡 Conseil

**Commencez simple** :
1. Lancez Jersey
2. Testez avec le navigateur
3. Ouvrez Grafana
4. Lancez UN test JMeter
5. Regardez les résultats

**Puis** :
- Testez les autres variants
- Comparez les résultats
- Lisez l'analyse

## 📞 Besoin d'Aide ?

- **Problème Docker** → `DOCKER_GUIDE.md`
- **Problème API** → `TEST_COMMANDS.md`
- **Problème JMeter** → `jmeter/README.md`
- **Questions générales** → `README.md`

---

## ⚡ TL;DR (Version Ultra-Courte)

```bash
# 1. Démarrer
docker-compose --profile jersey --profile monitoring up -d

# 2. Attendre 2 minutes

# 3. Tester
curl http://localhost:8081/items?page=0&size=10

# 4. Ouvrir Grafana
start http://localhost:3000

# 5. Lancer un test
cd jmeter
python generate-jmx.py
jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l ../results/test.jtl

# 6. Voir les résultats
jmeter -g results/test.jtl -o results/test-report
start results/test-report/index.html
```

---

**C'est parti ! 🚀**

Prochaine étape : Ouvrir `QUICK_START.md` ou lancer `docker-start.bat`
