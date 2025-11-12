FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy common module first
COPY common/pom.xml /app/common/
COPY common/src /app/common/src
RUN cd common && mvn clean install -DskipTests

# Copy and build variant-a-jersey
COPY variant-a-jersey/pom.xml .
COPY variant-a-jersey/src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8081

ENV JAVA_OPTS="-Xms512m -Xmx1024m"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
