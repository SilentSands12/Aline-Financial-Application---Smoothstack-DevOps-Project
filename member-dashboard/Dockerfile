# Dockerfile for Dockerizing an Angular Member Dashboard Application
#
# This Dockerfile contains multi-stage builds to efficiently build and deploy
# an Angular application using Node.js and Nginx.
#
# -------------------------WORKED STAGE 1---------------------------------
# Build stage
FROM node:14-alpine as builder
# Use Node.js Alpine image as the build stage

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY . .

# Install dependencies
RUN npm install

# Build the application
RUN npm run build

# ----------------WORKED STAGE 2 SIZE COMPRESSION -----------------------
# Use Nginx Alpine image for the execution stage
FROM nginx:alpine

# Remove default Nginx index.html and 50x.html files
RUN rm -f /usr/share/nginx/html/index.html \
    && rm -f /usr/share/nginx/html/50x.html

# Copy the built files from the build stage to Nginx's HTML directory
COPY  --from=builder /app/dist/aline-member-dashboard /usr/share/nginx/html

# Expose port 80 because of nginx 80 default
EXPOSE 80

# Start Nginx with the specified configuration
CMD ["nginx", "-g", "daemon off;"]

# ----------------------------------------------------------------------------
# Dockerignore file contents:
#   node_modules
#   npm-debug.log
#   dist
#   .DS_Store
#   *.log
#   package-lock.json
#
# These files and directories are excluded from being copied into the Docker
# image to ensure a smaller and more efficient build.
#
# ----------------------------------------------------------------------------
