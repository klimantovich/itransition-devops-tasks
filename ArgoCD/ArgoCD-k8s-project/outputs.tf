output "rds-endpoint" {
  description = "Endpoint Address + Port"
  value       = module.dev_db.instance_endpoint
}

output "eks-init" {
  value = "aws eks update-kubeconfig --region=${var.aws_region} --name=${local.cluster_name}"
}

output "ingress_endpoint" {
  value = module.dev_eks.ingress_endpoint
}

output "argocd_url" {
  value = "https://argocd.klim4ntovich.online"
}

output "project_url" {
  value = "https://project.klim4ntovich.online"
}
