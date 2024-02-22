#-----------------------------------------------
# Common variables
#-----------------------------------------------
variable "aws_region" {
  description = "(Required) AWS region for VPC resources"
  type        = string
  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
    error_message = "Must be valid AWS Region name."
  }
}

variable "environment" {
  description = "Environment prefix"
  type        = string
}

#-----------------------------------------------
# Network variables
#-----------------------------------------------
variable "vpc_cidr" {
  description = "VPC CIDR where resources will be placed in"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Variable vpc_cidr must contain valid IPv4 CIDRs."
  }
}

#-----------------------------------------------
# EKS variables
#-----------------------------------------------
variable "cluster_kubernetes_version" {
  description = "Kubernetes version for EKS cluster. If you do not specify a value, the latest available version at resource creation is used"
  type        = number
  validation {
    condition     = var.cluster_kubernetes_version >= 1.23
    error_message = "kubernetes version should be v1.23 or newer"
  }
}

variable "cluster_endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled. Default is false"
  type        = bool
}

variable "nodegroup_desired_size" {
  description = "(Required) Desired number of worker nodes"
  type        = number
  validation {
    condition     = var.nodegroup_desired_size >= 0
    error_message = "Desired nodes count should be >= 0"
  }
}
variable "nodegroup_max_size" {
  description = "(Required) Maximum number of worker nodes"
  type        = number
  validation {
    condition     = var.nodegroup_max_size >= 1
    error_message = "Maximum nodegroup size number should be >= 1"
  }
}
variable "nodegroup_min_size" {
  description = "(Required) Minimum number of worker nodes"
  type        = number
  validation {
    condition     = var.nodegroup_min_size >= 0
    error_message = "Minimal nodes number should be >= 0"
  }
}

variable "nodegroup_instance_types" {
  description = "List of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]"
  type        = list(string)
}

variable "ingress_enabled" {
  description = "(Required) Set true to install ingress controller"
  type        = bool
}

variable "ingress_release_name" {
  description = "(Required) Release name. The length must not be longer than 53 characters."
  type        = string
  validation {
    condition     = length(var.ingress_release_name) <= 53
    error_message = "Release name length must not be longer than 53 characters"
  }
}

variable "ingress_create_namespace" {
  description = "Create the namespace if it does not yet exist. Defaults to false"
  type        = bool
}

variable "ingress_namespace" {
  description = "The namespace to install the release into"
  type        = string
}

#-----------------------------------------------
# Database variables
#-----------------------------------------------
variable "security_group_db_port" {
  description = "DB port for security groups (like 3306 for mysql etc.)"
  type        = number
}

variable "db_allocated_storage" {
  description = "(Required unless a replicate_source_db is provided) The allocated storage in gibibytes"
  type        = number
  validation {
    condition     = var.db_allocated_storage > 0
    error_message = "Allocated storage should be > 0 Gb."
  }
}

variable "db_engine" {
  description = "The engine version to use"
  type        = string
}

variable "db_engine_version" {
  description = "The database engine to use (https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html)"
  type        = string
}

variable "db_instance_class" {
  description = "(Required) The instance type of the RDS instance (example: db.t3.micro)"
  type        = string
  validation {
    condition     = can(regex("db.[a-z]+", var.db_instance_class))
    error_message = "Instance class name should begin from db (db.t3.micro etc)"
  }
}

variable "db_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created"
  type        = bool
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
}

variable "db_user" {
  description = "Database master User which will be used"
  type        = string
}

#-----------------------------------------------
# Argocd variables
#-----------------------------------------------
variable "argocd_repository" {
  description = "ArgoCD Repository URL"
  type        = string
  validation {
    condition     = can(regex("https://.+", var.argocd_repository))
    error_message = "ArgoCD repository url must be https://<URL>"
  }
}

variable "argocd_chart_create_namespace" {
  description = "Set true if you want ArgoCD to create namespace for it's resources, or false to use default namespace"
  type        = string
}

variable "argocd_chart_namespace" {
  description = "(If variable argocd_chart_create_namespace = true) Name of namespace where argocd resources are located"
  type        = string
}

variable "argocd_chart_version" {
  description = "ArgoCD Chart Version"
  type        = string
}

variable "argocd_values_path" {
  description = "Path to ArgoCD chart values.yaml file"
  type        = string
}

variable "argocd_project_name" {
  description = "ArgoCD custom project name"
  type        = string
}

#-----------------------------------------------
# Project variables
#-----------------------------------------------
variable "project_application_name" {
  description = "ArgoCD application title"
  type        = string
}

variable "project_repository" {
  description = "Project github repository"
  type        = string
  validation {
    condition     = can(regex("https://.+", var.project_repository))
    error_message = "Repository url must be https://<URL>"
  }
}

variable "project_repository_branch" {
  description = "Project github repository branch"
  type        = string
}

variable "project_repository_path" {
  description = "Path to chart folder in project github repo"
  type        = string
}

variable "project_namespace" {
  description = "Kubernetes namespace for project resources"
  type        = string
}

variable "httpAuthUser" {
  default = "User for HTTP Basic Auth"
  type    = string
}

#-----------------------------------------------
# Google Secret Manager variables
#-----------------------------------------------
variable "gsm_project" {
  description = "GCP project ID where Secret Manager is located"
  type        = string
}

variable "gsm_httpAuth_password_secret" {
  description = "GCP Secret Manager httpAuth_password Secret name"
  type        = string
}

variable "gsm_db_password_secret" {
  description = "GCP Secret Manager database password Secret name"
  type        = string
}
