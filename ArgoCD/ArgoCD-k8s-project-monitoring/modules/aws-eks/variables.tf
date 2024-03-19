#-----------------------------------------------
# Common variables
#-----------------------------------------------
variable "environment" {
  description = "Environment prefix for AWS VPC resources"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS Region for Cluster"
  default     = "us-west-2"
}

#-----------------------------------------------
# EKS Cluster variables
#-----------------------------------------------
variable "cluster_name" {
  description = "(Required) EKS cluster name"
  type        = string
  default     = ""
  validation {
    condition     = can(regex("^[0-9A-Za-z][A-Za-z0-9\\-_]+$", var.cluster_name))
    error_message = "Cluster name must begin with an alphanumeric character, and must only contain alphanumeric characters, dashes and underscores"
  }
}

variable "cluster_kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = number
  default     = null
  validation {
    condition     = var.cluster_kubernetes_version >= 1.23
    error_message = "kubernetes version should be v1.23 or newer"
  }
}

variable "cluster_endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = null
}

variable "cluster_public_access_cidrs" {
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. default is [0.0.0.0/0]"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition     = can([for cidr in var.cluster_public_access_cidrs : cidrhost(cidr, 0)])
    error_message = "Variable cluster_public_access_cidrs must contain valid IPv4 CIDRs."
  }
}

variable "cluster_subnet_ids" {
  description = "(Required) List of subnet IDs. Must be in at least two different availability zones"
  type        = list(string)
  default     = []
}

#-----------------------------------------------
# EKS Managed Node Group variables
#-----------------------------------------------
variable "nodegroup_subnet_ids" {
  description = "(Required) List of identifiers of EC2 Subnets to associate with the EKS Node Group"
  type        = list(string)
  default     = []
}

variable "nodegroup_desired_size" {
  description = "(Required) Desired number of worker nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.nodegroup_desired_size >= 0
    error_message = "Desired nodes count should be >= 0"
  }
}
variable "nodegroup_max_size" {
  description = "(Required) Maximum number of worker nodes"
  type        = number
  default     = 1
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

variable "nodegroup_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Allowed values is ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "nodegroup_disk_size" {
  description = "Disk size in GiB for worker nodes. Defaults to 20Gb"
  type        = number
  default     = null
}

variable "nodegroup_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. For valid values see https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType"
  type        = string
  default     = null
}

variable "nodegroup_instance_types" {
  description = "List of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]"
  type        = list(string)
  default     = null
}

variable "nodegroup_labels" {
  description = "Key-value map of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
  type        = map(string)
  default     = null
}

variable "nodegroup_max_unavailable" {
  description = "Desired max number of unavailable worker nodes during node group update"
  type        = number
  default     = 1
}

#-----------------------------------------------
# Helm chart - nginx ingress controller
#-----------------------------------------------
variable "ingress_enabled" {
  description = "Set true to install ingress controller"
  type        = bool
  default     = false
}

variable "ingress_release_name" {
  description = "(Required) Release name. The length must not be longer than 53 characters."
  type        = string
  default     = ""
  validation {
    condition     = length(var.ingress_release_name) <= 53
    error_message = "Release name length must not be longer than 53 characters"
  }
}

variable "ingress_chart" {
  description = "(Required) Chart name to be installed."
  type        = string
  default     = "ingress-nginx"
}

variable "ingress_repository" {
  description = "Repository URL where to locate the requested chart."
  type        = string
  default     = "https://kubernetes.github.io/ingress-nginx"
}

variable "ingress_chart_version" {
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed"
  type        = string
  default     = null
}

variable "ingress_atomic" {
  description = "If set, installation process purges chart on fail. Defaults to false."
  type        = bool
  default     = null
}

variable "ingress_create_namespace" {
  description = "Create the namespace if it does not yet exist. Defaults to false"
  type        = bool
  default     = null
}

variable "ingress_namespace" {
  description = "The namespace to install the release into. Defaults to \"default\""
  type        = string
  default     = null
}

variable "ingress_chart_options" {
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "controller.ingressClassResource.name"
      value = "nginx"
    },
    {
      name  = "controller.ingressClassResource.default"
      value = "true"
    },
  ]
}
