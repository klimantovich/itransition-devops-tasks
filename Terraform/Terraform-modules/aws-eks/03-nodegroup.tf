locals {
  create_node_group = length(var.nodegroup_subnet_ids) > 0 ? true : false
}

resource "aws_eks_node_group" "worker_nodes" {
  count = local.create_node_group ? 1 : 0

  # Required
  cluster_name  = aws_eks_cluster.cluster.name
  node_role_arn = join("", aws_iam_role.worker_nodes[*].arn)
  subnet_ids    = var.nodegroup_subnet_ids
  scaling_config {
    desired_size = var.nodegroup_desired_size
    max_size     = var.nodegroup_max_size
    min_size     = var.nodegroup_min_size
  }

  node_group_name = "${aws_eks_cluster.cluster.name}-worker-nodes"
  capacity_type   = var.nodegroup_capacity_type

  ami_type       = var.nodegroup_ami_type
  instance_types = var.nodegroup_instance_types
  disk_size      = var.nodegroup_disk_size

  labels = var.nodegroup_labels

  update_config {
    max_unavailable = var.nodegroup_max_unavailable
  }

  depends_on = [
    aws_iam_role_policy_attachment.eksWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_CNI_Policy,
    aws_iam_role_policy_attachment.ec2ContainerRegistryReadOnly
  ]
}

#-----------------------------------------------
# Node service IAM role
#-----------------------------------------------
resource "aws_iam_role" "worker_nodes" {
  count = local.create_node_group ? 1 : 0

  name = "eksWorkerNodeRole"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eksWorkerNodePolicy" {
  count = local.create_node_group ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = join("", aws_iam_role.worker_nodes[*].name)
}

resource "aws_iam_role_policy_attachment" "eks_CNI_Policy" {
  count = local.create_node_group ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = join("", aws_iam_role.worker_nodes[*].name)
}

resource "aws_iam_role_policy_attachment" "ec2ContainerRegistryReadOnly" {
  count = local.create_node_group ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = join("", aws_iam_role.worker_nodes[*].name)
}
