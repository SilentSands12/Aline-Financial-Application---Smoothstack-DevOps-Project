# Development Environment:

#     Frequent changes, so you might not need to optimize the image size.
#     Easier debugging, so tools and additional libraries might be included.
#     Use -DskipTests during builds to speed up the process, as shown.

# Production Environment:

#     Optimized for performance and security.
#     Smaller image size to reduce attack surface and improve deployment speed.
#     Ensure all tests are run to catch issues before deployment.
#     Use environment variables and secrets management for sensitive data.

# ------------------------------ Production Build -------------------------------
# Build stage
FROM maven:3.8.4-openjdk-17 AS builder

# Set working directory
WORKDIR /app

# Copy the Maven project file and source code
COPY core ./core
COPY user-microservice ./user-microservice
COPY pom.xml .

# Build the application
RUN mvn clean package -DskipTests

# Execution stage
FROM openjdk:17-alpine

# Set working directory
WORKDIR /app

# Copy built JAR file from the build stage
COPY --from=builder /app/user-microservice/target/user-microservice-0.1.0.jar .

# Expose the port on which the microservice will run
EXPOSE 8070

# Set the entrypoint to run your application
ENTRYPOINT ["java", "-jar", "user-microservice-0.1.0.jar"]
