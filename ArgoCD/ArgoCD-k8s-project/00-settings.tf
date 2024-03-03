# https://developer.hashicorp.com/terraform/language/settings/backends/gcs

terraform {
  required_version = "~> 1.6.2"

  backend "gcs" {
    bucket = "argocd-k8s-project-bucket-tfstate"
    prefix = "terraform/state"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.18.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.26.0"
    }
  }
}
