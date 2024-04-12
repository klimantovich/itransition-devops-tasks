# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      "kubernetes.io/cluster/kubernetes" = "owned"
    }
  }
}
