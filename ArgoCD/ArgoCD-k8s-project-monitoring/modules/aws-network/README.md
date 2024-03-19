# Terraform module aws-network  
general purpose: create VPC resources on AWS provider.  
By default creates VPC of the following configuration:  
- VPC
- Public subnet x2
- Private subnet x2
- Private route table x2
- Public route table
- NAT Gateway x2
- Internet gateway

## Usage
```
module "dev_network" {
  source = "git@github.com:klimantovich/terraform-modules.git//aws-network"

  aws_region  = var.aws_region
  vpc_cidr    = var.vpc_cidr
  environment = var.environment

}
```

## Requirements
terraform >= 1.0
aws provider >= 5.20

## Inputs
`aws_region`: default = "us-west-2"  
`vpc_cidr`: default = "10.0.0.0/16"  
`environment`: default = "test"  
Optional:  
`public_subnet_count`: default = 2  
`private_subnet_count`: default = 2  

## Outputs:
`vpc_id`  
`public_subnet_ids`  
`private_subnet_ids`  
