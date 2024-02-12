output "eks-init" {
  value = "aws eks update-kubeconfig --region=${var.aws_region} --name=${local.cluster_name}"
}
