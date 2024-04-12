variable "aws_access_key_id" {
  description = "(Required) AWS Access Key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "(Required) AWS Secret Access Key"
  type        = string
}

variable "aws_region" {
  description = "(Required) AWS region for VPC resources"
  type        = string
  default     = ""
  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
    error_message = "Must be valid AWS Region name."
  }
}

variable "environment" {
  description = "Environment prefix"
  type        = string
  default     = ""
}

variable "k8s_vpc_cidr" {
  description = "VPC CIDR where resources will be placed in"
  type        = string
  default     = ""
  validation {
    condition     = can(cidrhost(var.k8s_vpc_cidr, 0))
    error_message = "Variable vpc_cidr must contain valid IPv4 CIDRs."
  }
}

variable "k8s_instances_ami" {
  description = "AMI for k8s nodes"
  type        = string
  default     = "ami-08116b9957a259459"
}

variable "k8s_api_loadbalancer_instance_type" {
  description = "Instance type for API loadbalancer (haproxy)"
  type        = string
  default     = ""
}

variable "k8s_master_instance_type" {
  description = "Instance type for Master Nodes (haproxy)"
  type        = string
  default     = ""
}

variable "k8s_worker_instance_type" {
  description = "Instance type for Worker Nodes (haproxy)"
  type        = string
  default     = ""
}

variable "k8s_master_nodes_count" {
  description = "Number of master nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.k8s_master_nodes_count % 2 != 0
    error_message = "Only not even nubmer of master nodes are accepted!"
  }
}

variable "k8s_worker_nodes_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 0
}

variable "k8s_pod_network_cidr" {
  description = "CIDR for cluster pods network"
  type        = string
  default     = ""
}
