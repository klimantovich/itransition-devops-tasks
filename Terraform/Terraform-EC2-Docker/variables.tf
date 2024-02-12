#-----------------
# Common variables
#-----------------
variable "aws_region" {
  description = "AWS region for VPC resources"
  default     = "us-west-2"
}
variable "vpc_cidr" {
  description = "VPC CIDR where resources will be placed in"
  default     = "10.5.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Variable vpc_cidr must contain valid IPv4 CIDRs."
  }
}
variable "environment" {
  description = "Environment prefix"
  default     = "dev"
}

#--------------
# EC2 variables
#--------------
variable "ami" {
  default = "ami-035bf26fb18e75d1b"
  validation {
    condition     = can(regex("^ami+", var.ami))
    error_message = "AMI variable should begin from ami-*"
  }
}
variable "path_to_local_key" {
  description = "Local private rsa key destination"
  default     = "./ec2.key"
}
variable "path_to_cloud_config_file" {
  description = "Destination of local cloud-config yaml file"
  default     = "./cloud-config.yaml"
}
variable "ec2_user_name" {
  description = "EC2 instance user name"
  default     = "ec2-user"
}

#------------------------
# Docker common variables
#------------------------

variable "mysql_data_volume_name" {
  description = "docker volume name for persistent DB data"
  default     = "db_data"
}
variable "common_restart_policy" {
  description = "Common restart policy for docker containers"
  default     = "always"
}
variable "repository" {
  description = "Repository from where pull images"
  default     = "klim4ntovich.online"
}

#------------------------------------
# Docker common environment variables
#------------------------------------
variable "mysql_database" {
  description = "MySQL database name"
  default     = "items_db"
}
variable "mysql_user" {
  description = "User name for web-app to connect to DB"
  default     = "root"
}
variable "mysql_password" {
  description = "User password for web-app to connect to DB"
  default     = "root1234"
  sensitive   = true
}

#--------------------
# Docker db variables
#--------------------
variable "db_container_name" {
  default = "db"
}
variable "db_image" {
  default = "mysql:8.0.34"
}
variable "initdb_host_path" {
  description = "EC2 instance path to init.sql file with sql schema"
  default     = "/home/ec2-user/init.sql"
}

#---------------------------
# Docker front app variables
#---------------------------
variable "front_container_name" {
  default = "front"
}
variable "frontend_image" {
  default = "frontend-app:latest"
}

#------------------------------
# Docker loadbalancer variables
#------------------------------
variable "lb_container_name" {
  default = "loadbalancer"
}
variable "loadbalancer_image" {
  default = "loadbalancer:latest"
}
variable "lb_internal_port" {
  description = "Nginx container port"
  default     = 80
}
variable "lb_external_port" {
  description = "Port to expose nginx lb"
  default     = 80
}
