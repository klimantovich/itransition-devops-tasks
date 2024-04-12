locals {
  # Secrets names
  kubeadm_token_secret_name           = "KubeadmJoinToken"
  kubeadm_token_hash_secret_name      = "KubeadmJoinTokenHash"
  kubeadm_kubeconfig_secret_name      = "KubeadmKubeconfig"
  kubeadm_certificate_key_secret_name = "KubeadmCertificateKey"
  # Subnets for worker nodes & control plane
  master_nodes_subnet = module.k8s_vpc.private_subnet_ids[0]
  worker_nodes_subnet = module.k8s_vpc.private_subnet_ids[0]
  # Generate static private IPs for master nodes
  # Master node ips x.x.x.100 - x.x.x.199, Worker nodes ips x.x.x.200 - x.x.x.254
  master_ip_offset           = 100                                                                           # ip, which master nodes ips start from
  master_nodes_subnet_prefix = regex("^\\d{1,3}.\\d{1,3}.\\d{1,3}.", module.k8s_vpc.private_subnet_cidrs[0]) # String subnet address without host ip
  master_nodes_private_ips   = formatlist("${local.master_nodes_subnet_prefix}%s", range(local.master_ip_offset, var.k8s_master_nodes_count + local.master_ip_offset))
  # Generate static private IPs for worker nodes
  worker_ip_offset           = 200                                                                           # ip, which worker nodes ips start from
  worker_nodes_subnet_prefix = regex("^\\d{1,3}.\\d{1,3}.\\d{1,3}.", module.k8s_vpc.private_subnet_cidrs[0]) # String subnet address without host ip
  worker_nodes_private_ips   = formatlist("${local.worker_nodes_subnet_prefix}%s", range(local.worker_ip_offset, var.k8s_worker_nodes_count + local.worker_ip_offset))
}

module "k8s_vpc" {
  source = "./modules/aws-network"

  aws_region  = var.aws_region
  vpc_cidr    = var.k8s_vpc_cidr
  environment = var.environment

}

module "loadbalancer-control-plane" {
  source = "./modules/aws-ec2"

  ec2_ami           = var.k8s_instances_ami
  ec2_instance_type = var.k8s_api_loadbalancer_instance_type

  ec2_associate_public_ip_address = true
  ec2_subnet_id                   = module.k8s_vpc.public_subnet_ids[0]
  ec2_vpc_security_group_ids      = [aws_security_group.k8s-lb.id]
  ec2_key_name                    = aws_key_pair.cluster.key_name

  ec2_user_data_replace_on_change = false
  ec2_user_data_base64 = base64encode(templatefile("${path.module}/scripts/setup-lb.tftpl",
    {
      hostname             = "lb",
      master_nodes_ips_map = zipmap(range(var.k8s_master_nodes_count), local.master_nodes_private_ips)
    }
  ))

  ec2_instance_tags = {
    Name = "lb"
  }
}

# Setup first control plane node (for kubeadm init command)
module "control-plane-init-node" {
  source = "./modules/aws-ec2"

  ec2_ami           = var.k8s_instances_ami
  ec2_instance_type = var.k8s_master_instance_type

  ec2_associate_public_ip_address = false
  ec2_private_ip                  = local.master_nodes_private_ips[0]
  ec2_subnet_id                   = local.master_nodes_subnet # Control Plane Subnet
  ec2_vpc_security_group_ids      = [aws_security_group.k8s-master.id]
  ec2_key_name                    = aws_key_pair.cluster.key_name
  ec2_iam_instance_profile        = aws_iam_instance_profile.k8s-control-node.name

  ec2_user_data_replace_on_change = false
  ec2_user_data_base64 = base64encode(templatefile("${path.module}/scripts/setup-master-initial-node.tftpl",
    {
      control_plane_endpoint              = module.loadbalancer-control-plane.public_ip
      aws_access_key_id                   = var.aws_access_key_id
      aws_secret_access_key               = var.aws_secret_access_key
      aws_default_region                  = var.aws_region
      kubeadm_token_secret_name           = local.kubeadm_token_secret_name
      kubeadm_token_hash_secret_name      = local.kubeadm_token_hash_secret_name
      kubeadm_kubeconfig_secret_name      = local.kubeadm_kubeconfig_secret_name
      kubeadm_certificate_key_secret_name = local.kubeadm_certificate_key_secret_name
      k8s_pod_network_cidr                = var.k8s_pod_network_cidr
    }
  ))

  ec2_instance_tags = {
    Name = "master-1"
  }

  depends_on = [module.loadbalancer-control-plane]
}

# Setup another control plane nodes (for kubeadm join command)
module "control-plane" {
  source = "./modules/aws-ec2"
  count  = var.k8s_master_nodes_count - 1

  ec2_ami           = var.k8s_instances_ami
  ec2_instance_type = var.k8s_master_instance_type

  ec2_associate_public_ip_address = false
  ec2_private_ip                  = local.master_nodes_private_ips[count.index + 1]
  ec2_subnet_id                   = local.master_nodes_subnet # Control Plane Subnet
  ec2_vpc_security_group_ids      = [aws_security_group.k8s-master.id]
  ec2_key_name                    = aws_key_pair.cluster.key_name
  ec2_iam_instance_profile        = aws_iam_instance_profile.k8s-control-node.name

  ec2_user_data_base64 = base64encode(templatefile("${path.module}/scripts/setup-master.tftpl",
    {
      control_plane_endpoint = module.loadbalancer-control-plane.public_ip
      token                  = data.aws_secretsmanager_secret_version.kubeadm-token.secret_string
      token_hash             = data.aws_secretsmanager_secret_version.kubeadm-token-hash.secret_string
      certificate_key        = data.aws_secretsmanager_secret_version.certificate-key.secret_string
    }
  ))

  ec2_instance_tags = {
    Name = "master-${count.index + 2}"
  }

  depends_on = [terraform_data.wait_for_kubeadm_initialization]
}

# Setup worker nodes
module "worker-nodes" {
  source = "./modules/aws-ec2"
  count  = var.k8s_worker_nodes_count

  ec2_ami           = var.k8s_instances_ami
  ec2_instance_type = var.k8s_worker_instance_type

  ec2_associate_public_ip_address = false
  ec2_private_ip                  = local.worker_nodes_private_ips[count.index]
  ec2_subnet_id                   = local.worker_nodes_subnet # Worker Nodes Subnet
  ec2_vpc_security_group_ids      = [aws_security_group.k8s-worker.id]
  ec2_key_name                    = aws_key_pair.cluster.key_name
  ec2_iam_instance_profile        = aws_iam_instance_profile.k8s-worker-node.name

  ec2_user_data_base64 = base64encode(templatefile("${path.module}/scripts/setup-worker.tftpl",
    {
      control_plane_endpoint = module.loadbalancer-control-plane.public_ip
      token                  = data.aws_secretsmanager_secret_version.kubeadm-token.secret_string
      token_hash             = data.aws_secretsmanager_secret_version.kubeadm-token-hash.secret_string
    }
  ))

  ec2_instance_tags = {
    Name = "worker-${count.index + 1}"
  }

  depends_on = [module.control-plane]
}

#----------------------------------------
# Security groups for cluster nodes
#----------------------------------------
resource "aws_security_group" "k8s-master" {
  name        = "K8S Master Ports"
  description = "Firewall rules for k8s Control Plane Nodes"
  vpc_id      = module.k8s_vpc.vpc_id

  # API Server, SSH
  dynamic "ingress" {
    for_each = [
      { description = "API Server", fromPort = "6443", toPort = "6443" },
      { description = "SSH", fromPort = "22", toPort = "22" },
      { description = "Calico networking with Typha enabled", fromPort = "5473", toPort = "5473" }
    ]
    content {
      description = ingress.value.description
      from_port   = ingress.value.fromPort
      to_port     = ingress.value.toPort
      protocol    = "tcp"
      cidr_blocks = [module.k8s_vpc.vpc_cidr]
    }
  }

  # ETCD, kubelet-api, scheduler, controller-manager inbound rules
  dynamic "ingress" {
    for_each = [
      { description = "etcd server client API", fromPort = "2379", toPort = "2380" },
      { description = "Kubelet API", fromPort = "10250", toPort = "10250" },
      { description = "kube-scheduler", fromPort = "10259", toPort = "10259" },
      { description = "kube-controller-manager", fromPort = "10257", toPort = "10257" }
    ]
    content {
      description = ingress.value.description
      from_port   = ingress.value.fromPort
      to_port     = ingress.value.toPort
      protocol    = "tcp"
      # cidr_blocks = [module.k8s_vpc.vpc_cidr]
      self = true
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "k8s-worker" {
  name        = "K8S Worker Ports"
  description = "Firewall rules for k8s Worker Nodes"
  vpc_id      = module.k8s_vpc.vpc_id

  # Kubelet API, NodePort Services
  dynamic "ingress" {
    for_each = [
      { description = "Kubelet API", fromPort = "10250", toPort = "10250", fromCidrs = [module.k8s_vpc.vpc_cidr] },
      { description = "Node Port", fromPort = "30000", toPort = "32767", fromCidrs = ["0.0.0.0/0"] },
      { description = "SSH", fromPort = "22", toPort = "22", fromCidrs = [module.k8s_vpc.vpc_cidr] },
      { description = "Calico networking with Typha enabled", fromPort = "5473", toPort = "5473", fromCidrs = [module.k8s_vpc.vpc_cidr] }
    ]
    content {
      description = ingress.value.description
      from_port   = ingress.value.fromPort
      to_port     = ingress.value.toPort
      protocol    = "tcp"
      cidr_blocks = ingress.value.fromCidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "k8s-lb" {
  name        = "K8S Loadbalancer Ports"
  description = "Firewall rules for k8s Load Balancer for control plane nodes"
  vpc_id      = module.k8s_vpc.vpc_id

  # API server inbound rule
  ingress {
    description = "API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["217.28.48.78/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#----------------------------------------
# Generate rsa key for cluster Nodes
#----------------------------------------
resource "aws_key_pair" "cluster" {
  key_name   = "cluster-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "rsa-key" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = "./${aws_key_pair.cluster.key_name}.pem"
  file_permission = "400"
}

#----------------------------------------
# Get kubeadm tokens from secrets
#----------------------------------------
resource "terraform_data" "wait_for_kubeadm_initialization" {
  # wait before secrets will be created (module.control-plane-init-node user-data is finished)
  provisioner "local-exec" {
    command     = <<-EOT
      aws secretsmanager describe-secret --secret-id ${local.kubeadm_certificate_key_secret_name} &> /dev/null
      while [ $? -ne 0 ]; do
          sleep 5
          aws secretsmanager describe-secret --secret-id ${local.kubeadm_certificate_key_secret_name} &> /dev/null
      done
  EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [module.control-plane-init-node]
}

data "aws_secretsmanager_secret" "kubeadm-token" {
  name       = local.kubeadm_token_secret_name
  depends_on = [terraform_data.wait_for_kubeadm_initialization]
}
data "aws_secretsmanager_secret_version" "kubeadm-token" {
  secret_id = data.aws_secretsmanager_secret.kubeadm-token.id
}

data "aws_secretsmanager_secret" "kubeadm-token-hash" {
  name       = local.kubeadm_token_hash_secret_name
  depends_on = [terraform_data.wait_for_kubeadm_initialization]
}
data "aws_secretsmanager_secret_version" "kubeadm-token-hash" {
  secret_id = data.aws_secretsmanager_secret.kubeadm-token-hash.id
}

data "aws_secretsmanager_secret" "kubeconfig" {
  name       = local.kubeadm_kubeconfig_secret_name
  depends_on = [terraform_data.wait_for_kubeadm_initialization]
}
data "aws_secretsmanager_secret_version" "kubeconfig" {
  secret_id = data.aws_secretsmanager_secret.kubeconfig.id
}

data "aws_secretsmanager_secret" "certificate-key" {
  name       = local.kubeadm_certificate_key_secret_name
  depends_on = [terraform_data.wait_for_kubeadm_initialization]
}
data "aws_secretsmanager_secret_version" "certificate-key" {
  secret_id = data.aws_secretsmanager_secret.certificate-key.id
}

# #----------------------------------------
# # IAM roles for cluster Nodes
# #----------------------------------------
resource "aws_iam_policy" "k8s-control-node" {
  name        = "k8s-control-node"
  description = "Policy for self-managed k8s master nodes"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeAvailabilityZones",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyVolume",
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteVolume",
          "ec2:DetachVolume",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DescribeVpcs",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:AttachLoadBalancerToSubnets",
          "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateLoadBalancerPolicy",
          "elasticloadbalancing:CreateLoadBalancerListeners",
          "elasticloadbalancing:ConfigureHealthCheck",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancerListeners",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DetachLoadBalancerFromSubnets",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancerPolicies",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
          "iam:CreateServiceLinkedRole",
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "k8s-control-node" {
  name = "k8s-control-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "k8s-control-node" {
  role       = aws_iam_role.k8s-control-node.name
  policy_arn = aws_iam_policy.k8s-control-node.arn
}


resource "aws_iam_policy" "k8s-worker-node" {
  name        = "k8s-worker-node"
  description = "Policy for self-managed k8s worker nodes"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "k8s-worker-node" {
  name = "k8s-worker-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "k8s-worker-node" {
  role       = aws_iam_role.k8s-worker-node.name
  policy_arn = aws_iam_policy.k8s-worker-node.arn
}

resource "aws_iam_instance_profile" "k8s-control-node" {
  name = "k8s-control-node-profile"
  role = aws_iam_role.k8s-control-node.name
}

resource "aws_iam_instance_profile" "k8s-worker-node" {
  name = "k8s-worker-node-profile"
  role = aws_iam_role.k8s-worker-node.name
}
