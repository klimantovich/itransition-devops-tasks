output "cluster_id" {
  description = "Cluster name"
  value       = aws_eks_cluster.cluster.id
}

output "cluster_security_group_id" {
  description = "EKS cluster security group id"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "endpoint" {
  description = "EKS Cluster endpoint"
  value       = aws_eks_cluster.cluster.endpoint
}

output "ca_certificate" {
  description = "EKS cluster CA Certificate"
  value       = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
}

output "node_group_id" {
  value = length(aws_eks_node_group.worker_nodes) > 0 ? aws_eks_node_group.worker_nodes[0].id : null
}

output "cluster_role_arn" {
  description = "Cluster Role ARN"
  value       = aws_iam_role.eksClusterRole.arn
}

output "cluster_role_name" {
  description = "Cluster Role ARN"
  value       = aws_iam_role.eksClusterRole.name
}

output "nodegroup_role_arn" {
  description = "Nodegroup Role ARN"
  value       = join("", aws_iam_role.worker_nodes[*].arn)
}

output "nodegroup_role_name" {
  description = "Nodegroup Role name"
  value       = join("", aws_iam_role.worker_nodes[*].name)
}

output "ingress_endpoint" {
  description = "k8s Ingress AWS ELB endpoint"
  value       = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.hostname
}
