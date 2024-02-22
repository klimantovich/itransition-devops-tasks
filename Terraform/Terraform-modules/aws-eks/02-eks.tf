resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_kubernetes_version
  role_arn = aws_iam_role.eksClusterRole.arn

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  vpc_config {
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_public_access_cidrs
    subnet_ids              = var.cluster_subnet_ids
  }

  tags = {
    Name        = "${var.environment}-eks-cluster"
    Environment = var.environment
  }

  depends_on = [aws_iam_role_policy_attachment.eksClusterPolicy]
}

#-----------------------------------------------
# Cluster service IAM role
#-----------------------------------------------
resource "aws_iam_role" "eksClusterRole" {
  name = "eksClusterRole"
  assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2008-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eksClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksClusterRole.name
}

#-----------------------------------------------
# Update kubeconfig file
#-----------------------------------------------
resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region=${var.aws_region} --name=${var.cluster_name}"
  }
  depends_on = [aws_eks_cluster.cluster]
}
