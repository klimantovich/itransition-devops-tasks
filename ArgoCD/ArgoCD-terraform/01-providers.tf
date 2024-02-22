provider "helm" {
  kubernetes {
    host                   = module.dev_eks.endpoint
    cluster_ca_certificate = module.dev_eks.ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.dev_eks.cluster_id]
      command     = "aws"
    }
  }
}
