# Dockerfile for Dockerizing Landing Portal Frontend Application
#
# This Dockerfile contains multi-stage builds to efficiently build and deploy
# a React frontend application using Node.js and Nginx.


# -------------------------WORKED STAGE 1---------------------------------
# Build stage
# Use a specific Node.js Alpine image as the build stage
FROM node:14.17.0-alpine as builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Build the application
RUN npm run build

# ----------------WORKED STAGE 2-----------------------
# Use Nginx Alpine image for the execution stage
FROM nginx:1.21.6-alpine

# Remove default Nginx index.html and 50x.html files
RUN rm -f /usr/share/nginx/html/index.html \
    && rm -f /usr/share/nginx/html/50x.html

# Copy the built files from the build stage to Nginx's HTML directory
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port 80 because of nginx 80 default
EXPOSE 80

# Start Nginx with the specified configuration
ENTRYPOINT ["nginx", "-g", "daemon off;"]


# ----------------------------------------------------------------------------
# Dockerignore file contents:
#   node_modules
#   npm-debug.log
#   build
#   .DS_Store
#   *.log
#
# These files and directories are excluded from being copied into the Docker
# image to ensure a smaller and more efficient build.
#
# ----------------------------------------------------------------------------