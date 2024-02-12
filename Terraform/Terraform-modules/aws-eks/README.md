# Terraform module aws-eks
general purpose: deploy EKS cluster on AWS provider.  
By default creates EKS ckuster with managed node group and nginx ingress controller.  

## Usage
Minimal required configuration:  
```
module "dev_eks" {
  source = "git@github.com:klimantovich/terraform-modules.git//aws-eks"

  aws_region  = <aws_region>
  vpc_cidr    = <vpc_cidr>

  eks_cluster_name   = <some-cluster-name>
  subnet_ids         = <list_of_subnet_ids>

  nodegroup_subnet_ids   = <list_of_subnet_ids>
  nodegroup_desired_size = <nubmer_of_nodes>
  nodegroup_max_size     = <nubmer_of_nodes>
  nodegroup_min_size     = <nubmer_of_nodes>
}
```  

If you need to use nginx ingress controller, you need specify it in such way:  
```
  ...
  ingress_enabled               = true
  ingress_release_name          = <ingress-nginx-release-name>
  ...
```

## Requirements
terraform >= 1.0
aws provider >= 5.20

## Inputs (for full list see inputs.tf)
- `aws_region`
- `vpc_cidr` 
- `environment`
- `eks_cluster_name`
- `kubernetes_version`
- `subnet_ids`
- `nodegroup_desired_size`
- `ingress_enabled`

## Outputs:
`cluster_id`  
`sg_id`  
`node_group_id`  
