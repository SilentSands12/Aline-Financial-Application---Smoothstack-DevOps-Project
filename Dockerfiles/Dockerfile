# Use the MySQL official image as base
FROM mysql:latest

# Set environment variables
ENV MYSQL_ROOT_PASSWORD /run/secrets/mysql_root_password
# ENV MYSQL_DATABASE aline_financial_db
# ENV MYSQL_USER admin
# ENV MYSQL_PASSWORD /run/secrets/mysql_password

# Expose ports
EXPOSE 3306

# Copy initialization scripts into the container
COPY ./init-scripts /docker-entrypoint-initdb.d

# Set volume for MySQL data
# VOLUME /C/Users/Canal/OneDrive/Desktop/stuff/Python Projects/SmoothStacks/capstone/Dockerfiles/data:/var/lib/mysql

# Start MySQL server when the container launches
CMD ["mysqld"]