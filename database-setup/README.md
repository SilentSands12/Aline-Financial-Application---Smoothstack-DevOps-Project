# Setting Up the MySQL Database for Aline Financial Project

This document outlines the steps required to set up a MySQL database for Aline Financial Spring Boot microservice project.

## Prerequisites

Before starting, make sure you have MySQL installed on your machine. You can install it using the link below:

- MySQL (https://dev.mysql.com/downloads/mysql/)

## Database Setup

1. Connect to MySQL CLI

   Open the terminal and connect to MySQL using the following command:

   ```
   mysql --user=root --password
   ```

   Use the password you craeted during setup.

2. Create a new database:

   Open the MySQL command line client and create a new database using the following command:

   ```
   CREATE DATABASE <database_name>;
   ```

   Replace `<database_name>` with the name you want to give to your database eg. aline

3. Create a new user:

   Next, create a new user with the appropriate permissions to access the database. Use the following command:

   ```
   CREATE USER '<username>'@'localhost' IDENTIFIED BY '<password>';
   ```

   Replace `<username>` and `<password>` with the username and password you want to use to access the database.

4. Grant privileges to the new user:

   Grant the necessary privileges to the user to access and modify the database. Use the following command:

   ```
   GRANT ALL PRIVILEGES ON <database_name>.* TO '<username>'@'localhost';
   ```

   This grants all privileges to the user for the database you created earlier.

5. Set the connection values as environment variables as specified in the `application.yml` for every project:

For example, if you created a database called `aline`, then `DB_NAME=aline`
For `JWT_SECRET_KEY`, the value has to be a valid JWT token. You can generate a random token on jwt.io

**These steps must be completed for all backend microservices except the Gateway**

## Conclusion

Congratulations! You have successfully set up a MySQL database for Aline Financial project. You can now use this database to store and retrieve data for the application.