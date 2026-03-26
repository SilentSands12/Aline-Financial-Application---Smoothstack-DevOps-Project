# Build stage
FROM maven:3.8.4-openjdk-17 AS builder

# Set working directory
WORKDIR /app

# Copy the Maven project file and source code
COPY core ./core
COPY account-microservice ./account-microservice
COPY pom.xml .

# Build the application
RUN mvn clean package -DskipTests

# Execution stage
FROM openjdk:17-alpine

# Set working directory
WORKDIR /app

# Copy built JAR file from the build stage
COPY --from=builder /app/account-microservice/target/account-microservice-0.1.0.jar .

# # Copy .env file into the container
# COPY --from=builder /app/account-microservice/src/main/resources/.env .

# Expose the port on which the microservice will run
EXPOSE 8072

# Run your application with environment variables loaded from .env file
CMD ["java", "-jar", "account-microservice-0.1.0.jar"]