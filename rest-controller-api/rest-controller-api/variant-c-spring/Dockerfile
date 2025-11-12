# ---------------- BUILDER ----------------
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /app

# Copier tout le projet multi-module
COPY . .

# Construire uniquement variant-c-spring et ses dépendances
RUN mvn -q -e -DskipTests -pl variant-c-spring -am package


# ---------------- IMAGE FINALE ----------------
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copier le jar construit
COPY --from=builder /app/variant-c-spring/target/*.jar app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "app.jar"]
