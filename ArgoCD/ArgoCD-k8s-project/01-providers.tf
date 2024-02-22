provider "helm" {
  kubernetes {
    host                   = module.dev_eks.endpoint
    cluster_ca_certificate = module.dev_eks.ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = module.dev_eks.endpoint
  cluster_ca_certificate = module.dev_eks.ca_certificate
}

