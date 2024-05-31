# Stage 1: Build the application
FROM maven:3.9.7 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Create the final image
FROM openjdk:17
EXPOSE 8080
COPY --from=builder /app/target/busybox-backend-0.0.1-SNAPSHOT.jar /busybox-backend.jar
ENTRYPOINT ["java", "-jar", "/busybox-backend.jar"]