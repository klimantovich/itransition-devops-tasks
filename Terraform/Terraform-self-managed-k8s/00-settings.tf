terraform {
  required_version = "~> 1.6.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }
}

provider "aws" {

  region = var.aws_region

  default_tags {
    tags = {
      "kubernetes.io/cluster/kubernetes" = "owned"
    }
  }
}
