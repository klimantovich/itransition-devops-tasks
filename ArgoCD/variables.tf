#-----------------------------------------------
# Common variables
#-----------------------------------------------
variable "aws_region" {
  description = "(Required) AWS region for VPC resources"
  type        = string
  default     = "us-west-2"
  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
    error_message = "Must be valid AWS Region name."
  }
}

variable "environment" {
  description = "Environment prefix"
  default     = "dev"
}

#-----------------------------------------------
# Network variables
#-----------------------------------------------
variable "vpc_cidr" {
  description = "VPC CIDR where resources will be placed in"
  default     = "10.5.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Variable vpc_cidr must contain valid IPv4 CIDRs."
  }
}

#-----------------------------------------------
# EKS variables
#-----------------------------------------------
variable "cluster_kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = number
  default     = 1.28
  validation {
    condition     = var.cluster_kubernetes_version >= 1.23
    error_message = "kubernetes version should be v1.23 or newer"
  }
}

variable "cluster_endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "nodegroup_desired_size" {
  description = "(Required) Desired number of worker nodes"
  type        = number
  default     = 2
  validation {
    condition     = var.nodegroup_desired_size >= 0
    error_message = "Desired nodes count should be >= 0"
  }
}
variable "nodegroup_max_size" {
  description = "(Required) Maximum number of worker nodes"
  type        = number
  default     = 2
  validation {
    condition     = var.nodegroup_max_size >= 1
    error_message = "Maximum nodegroup size number should be >= 1"
  }
}
variable "nodegroup_min_size" {
  description = "(Required) Minimum number of worker nodes"
  type        = number
  default     = 0
  validation {
    condition     = var.nodegroup_min_size >= 0
    error_message = "Minimal nodes number should be >= 0"
  }
}

variable "nodegroup_instance_types" {
  description = "List of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]"
  type        = list(string)
  default     = ["t2.small"]
}

variable "ingress_enabled" {
  description = "Set true to install ingress controller"
  type        = bool
  default     = true
}

variable "ingress_release_name" {
  description = "(Required) Release name. The length must not be longer than 53 characters."
  type        = string
  default     = "ingress-nginx"
  validation {
    condition     = length(var.ingress_release_name) <= 53
    error_message = "Release name length must not be longer than 53 characters"
  }
}

variable "ingress_create_namespace" {
  description = "Create the namespace if it does not yet exist. Defaults to false"
  type        = bool
  default     = true
}

variable "ingress_namespace" {
  description = "The namespace to install the release into. Defaults to \"default\""
  type        = string
  default     = "ingress"
}

#-----------------------------------------------
# Argocd variables
#-----------------------------------------------
variable "argocd_repository" {
  description = "ArgoCD Repository"
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}

variable "argocd_chart_create_namespace" {
  description = "ArgoCD Repository"
  type        = string
  default     = true
}

variable "argocd_chart_namespace" {
  description = "ArgoCD Namespace"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "ArgoCD Chart Version"
  type        = string
  default     = "5.46.2"
}

variable "argocd_values_path" {
  description = "Path to ArgoCD chart values.yaml file"
  type        = string
  default     = "./manifests/argocd-config.yaml"
}

variable "argocd_admin_password" {
  default   = ""
  sensitive = true
}
