# Build stage
FROM maven:3.8.4-openjdk-17-slim AS builder

# Set working directory
WORKDIR /app

# Copy the Maven project file and source code
COPY . .

# Build the application
RUN mvn clean package -DskipTests

# Execution stage
FROM openjdk:17-alpine

# Set working directory
WORKDIR /app

# Copy built JAR file from the build stage
COPY --from=builder /app/target/aline-gateway-0.0.1-SNAPSHOT.jar .
# COPY --from=builder /app/src/main/resources/.env .

# Expose the port on which the microservice will run
EXPOSE 8080

# Run your application
CMD ["java", "-jar", "aline-gateway-0.0.1-SNAPSHOT.jar"]
# Execution stage

# FROM openjdk:17-alpine

# # Set working directory
# WORKDIR /app

# # Copy built JAR file from the build stage
# COPY target/aline-gateway-0.0.1-SNAPSHOT.jar .

# # Expose the port on which the microservice will run
# EXPOSE 8080

# # Run your application with environment variables loaded from .env file
# CMD ["java", "-jar", "aline-gateway-0.0.1-SNAPSHOT.jar"]