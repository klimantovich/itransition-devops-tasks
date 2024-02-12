output "cluster_id" {
  value = aws_eks_cluster.cluster.id
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
