# 1.Docker-compose task v1.0

## Description
Simple web application on python(flask) + MySQL / docker-compose.

## Run application
To run the application you need to have linux-based OS with installed docker-compose v.2.22.0 (https://github.com/docker/compose/releases/tag/v2.22.0)
Create .env file and define DB password & DB root password (take .env.exaple file as an example).  
Run the command `docker-compose up -d` to run the app on your local os.  
Run `docker ps` to ensure that all of containers are up and running.

## How to use application
Two main features:
1. Try to access http://localhost:80 url to view page with the hostname of the container to which the loadbalancer has forwarded you.
2. Access the url http://localhost:80/read to read data from connected database.  

P.S. to write data to Database you need to attach to the mysql container directly: `docker exec -it mysql_contaner_name bash`, connect mysql inside contauner and insert new values into db. If the container is reloaded, the data in the database will be preserved, because it has persistent volume. 