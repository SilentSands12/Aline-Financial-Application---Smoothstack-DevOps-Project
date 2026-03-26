# start-here

## Documentation

- For a quick overview of the application, check out the high-level-architecture diagram in this repo.

- For more information on the application api endpoints, check out the api-documentation in this repo.

## Prerequisite

- Java (17 or prior version)
- Node

## Getting started

- The project must be set up in a specific order due to some services being dependant on some other services. You should follow the following order when setting up the project:

- [] MySQL (None of the Java-based microservices will run if the connection to the DB is not made.)
- [] aline-user-microservice
- [] aline-underwriter-microservice
- [] aline-bank-microservice
- [] aline-account-microservice
- [] aline-transaction-microservice
- [] aline-gateway
- [] aline-admin-portal
- [] aline-landing-portal
- [] member-dashboard

## Making API calls

- Each microservice has Swagger documentation that provides information on how to interract with the endpoints
- Some endpoints are protected and therefore, you need to create an admin user using the /users/registration endpoint in user microservice.
- The created admin user can be used to log in via /login endpoint and get back a token from the response header. This token can then be should then be added to the authorization header when making the request

## Connecting Frontend to Backend

- The frontend portals communicate to the backend through aline-gateway by specifying the URL where the gateway is running at
