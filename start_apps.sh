#!/bin/bash

# Define the directories for microservices and UI applications
MICROSERVICES_DIR="/c/Users/Canal/OneDrive/Desktop/stuff/Python Projects/SmoothStacks/capstone"
UI_APPS_DIR="$MICROSERVICES_DIR"

# Function to start microservices
start_microservice() {
    echo "Starting $1 microservice..."
    cd "$MICROSERVICES_DIR/$1"
    java -jar "./$2/target/$2-0.1.0.jar" &
}

# Start microservices
start_microservice "aline-user-microservice" "user-microservice"
start_microservice "aline-underwriter-microservice" "underwriter-microservice"
start_microservice "aline-bank-microservice" "bank-microservice"
start_microservice "aline-account-microservice" "account-microservice"
start_microservice "aline-transaction-microservice" "transaction-microservice"

# Start gateway
echo "Starting gateway..."
cd "$MICROSERVICES_DIR/aline-gateway"
java -jar "./target/aline-gateway-0.0.1-SNAPSHOT.jar" &

# Start UI applications
echo "Starting UI applications..."
cd "$UI_APPS_DIR/aline-landing-portal"
npm start &
cd "$UI_APPS_DIR/aline-admin-portal"
npm start &

# Start Angular application
echo "Starting Angular application..."
cd "$UI_APPS_DIR/member-dashboard"
ng serve &

# Wait for Enter key to delete stuff
read -p "Press Enter to stop all applications..."
# Get the PIDs of processes with "node.js" or "java" in the STIME command field
pids=$(ps -ef | grep -E 'nodejs|java' | grep -v grep | awk '{print $2}')

# Terminate each PID
for pid in $pids; do
    echo "Terminating PID: $pid"
    kill $pid
done
