# Build stage
FROM maven:3.8.4-openjdk-17 AS builder

# Set working directory
WORKDIR /app

# Copy the Maven project file and source code
COPY core ./core
COPY transaction-microservice ./transaction-microservice
COPY pom.xml .

# Build the application
RUN mvn clean package -DskipTests

# Execution stage
FROM openjdk:17-alpine

# Set working directory
WORKDIR /app

# Copy built JAR file from the build stage
COPY --from=builder /app/transaction-microservice/target/transaction-microservice-0.1.0.jar .

# # Copy .env file into the container
# COPY --from=builder /app/transaction-microservice/src/main/resources/.env .

# Expose the port on which the microservice will run
EXPOSE 8073

# Run your application with environment variables loaded from .env file
CMD ["java", "-jar", "transaction-microservice-0.1.0.jar"]