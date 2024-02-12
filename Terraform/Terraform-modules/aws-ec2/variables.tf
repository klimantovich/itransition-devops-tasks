# variable "aws_region" {
#   description = "(Required) AWS region for VPC resources"
#   type        = string
#   default     = ""
#   validation {
#     condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
#     error_message = "Must be valid AWS Region name."
#   }
# }

variable "environment" {
  description = "Environment prefix for AWS VPC resources"
  type        = string
  default     = ""
}

#----------------------------------------
##### Key pair for ec2 instance variables
#----------------------------------------

variable "ec2_key_pair_name" {
  description = "Name of key pair"
  type        = string
  default     = ""
}
variable "ec2_private_key_path" {
  description = "/path/to/private_key"
  type        = string
  default     = ""
}

#---------------------------
##### EC2 instance variables
#---------------------------

variable "ec2_ami" {
  description = "AMI to use for the instance"
  type        = string
  default     = null
}

variable "ec2_associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = null
}

variable "ec2_availability_zone" {
  description = "AZ to start the instance in"
  type        = string
  default     = null
}

variable "ec2_instance_type" {
  description = "Instance type to use for the instance"
  type        = string
  default     = "t2.micro"
}

variable "ec2_subnet_id" {
  description = "VPC Subnet ID to launch in."
  type        = string
  default     = null
}

variable "ec2_vpc_security_group_ids" {
  description = "List of security group names to associate with"
  type        = list(string)
  default     = null
}

variable "ec2_delete_on_termination" {
  type    = bool
  default = null
}
variable "ec2_volume_size" {
  type    = number
  default = null
}

#---------------
##### cloud-init
#---------------

variable "ec2_cloud_init_file_path" {
  description = "The user data to provide when launching the instance. File path. Set if you want to provide user-data"
  type        = string
  default     = null
}

variable "ec2_user_data_replace_on_change" {
  description = "When used in combination with user_data will trigger a destroy and recreate when set to true. Defaults to false if not set."
  type        = bool
  default     = null
}
