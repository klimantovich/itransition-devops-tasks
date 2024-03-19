# Terraform module aws-eks
general purpose: deploy RDS instance on AWS provider.  
By default creates RDS instance, subnet group & security group for it.  

## Usage
Example configuration:  
```
module "dev_db" {
  source = "git@github.com:klimantovich/terraform-modules.git//aws-rds"

  # security group variables
  db_vpc_id              = <vpc_id>
  db_port                = "3306"
  db_ingress_security_group_ids = <list_of_ingress_sg>

  # instance variables
  db_multi_az            = false
  db_allocated_storage   = 20
  db_engine              = "mysql"
  db_engine_version      = "8.0"

  db_instance_class      = "db.t3.small"

  # subnet group variables
  subnet_ids        = module.dev_network.private_subnet_ids
}
```  

## Requirements
terraform >= 1.0
aws provider >= 5.20

## Outputs:
`instance_id` - Identifier of instance  
`subnet_group_id` - DB subnet group id  
`security_group_id` -  DB security group id  
`instance_address` - The hostname of the RDS instance  
`instance_endpoint` - Endpoint of the instance  
