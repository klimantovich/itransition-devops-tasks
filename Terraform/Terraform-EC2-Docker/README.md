# Terraform
Create EC2 with pre-installed docker & run containerized web application 
## Usage
!OBLIGATORY STEP: You need to define db passwords: `mysql_password` & `mysql_root_password` input variables (file inputs.tf)  
download & init modules: `terraform init`  
plan: `terraform plan`  
deploy resources: `terraform apply`  
Optional:  
destroy all resources: `terraform destroy`  
