locals {
  cluster_name       = "${var.environment}-eks-cluster"
  cluster_subnet_ids = concat(module.dev_network.public_subnet_ids, module.dev_network.private_subnet_ids)
}

module "dev_eks" {
  source = "./modules/aws-eks" # git@github.com:klimantovich/itransition-devops-tasks.git//Terraform/Terraform-modules/aws-eks

  environment = var.environment

  cluster_name                    = local.cluster_name
  cluster_kubernetes_version      = var.cluster_kubernetes_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_subnet_ids              = local.cluster_subnet_ids

  nodegroup_subnet_ids     = module.dev_network.private_subnet_ids
  nodegroup_desired_size   = var.nodegroup_desired_size
  nodegroup_min_size       = var.nodegroup_min_size
  nodegroup_max_size       = var.nodegroup_max_size
  nodegroup_instance_types = var.nodegroup_instance_types

  ingress_enabled          = var.ingress_enabled
  ingress_release_name     = var.ingress_release_name
  ingress_create_namespace = var.ingress_create_namespace
  ingress_namespace        = var.ingress_namespace

}
