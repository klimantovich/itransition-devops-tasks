variable "aws_region" {
  description = "(Required) AWS region for VPC resources"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "(Required) VPC CIDR block"
  type        = string
  default     = ""
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The VPC subnet must be valid IPv4 CIDR."
  }
}

variable "environment" {
  description = "Environment prefix for AWS VPC resources"
  type        = string
  default     = ""
}

variable "public_subnet_count" {
  description = "(Optional) Number of public subnets on VPC. Default is 2"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "(Optional) Number of private subnets on VPC. Default is 2"
  type        = number
  default     = 2
}
