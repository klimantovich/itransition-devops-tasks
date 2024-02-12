# 2. Kubernetes / minikube task

## Description
Simple web application on python(flask) + MySQL / k8s / helm / minikube.

## Run application
To run the application you need to have linux-based OS with installed docker, minikube (used v1.31.2) and helm (v3.13.1).  
To run app you need to do next steps:  

1. Edit db-dev-values.yaml & frontend-dev-values.yaml files (use .example files as examples) or create your custom values files for db and frontend charts. Here you need to define database-related variables (such as db_user, db_password, db_host, password for ingress, etc).  
2. Run minikube cluster (minikube start)  
3. Intstall mysqldb & frontend charts with custom values files (from #1). For example:  
`helm install mysqldb ./charts/mysqldb -f your_file_with_custom_values.yaml`  

Edit local /etc/hosts file and add new record there: `127.0.0.1       myapp.example.com`.
Run `minikube tunnel` and open myapp.example.com on your browser.

## How to use application
Two main features:
1. Try to access http://myapp.example.com:80 url to view page with the hostname of the container to which the loadbalancer has forwarded you.
2. Access the url http://myapp.example.com:80/read to read data from connected database.  

P.S. to write data to Database you need to attach to the mysql container directly: `kubectl exec -it pod/db-mysql-0 -- bash`, connect mysql inside contauner and insert new values into db. If the container is reloaded, the data in the database will be preserved, because it has persistent volume. 
