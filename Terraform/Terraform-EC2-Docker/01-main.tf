module "dev_network" {
  source = "git@github.com:klimantovich/terraform-modules.git//aws-network"

  aws_region  = var.aws_region
  vpc_cidr    = var.vpc_cidr
  environment = var.environment

}

module "dev_ec2" {
  source = "git@github.com:klimantovich/terraform-modules.git//aws-ec2"

  # Amazon linux
  ec2_ami = var.ami

  aws_region                 = var.aws_region
  ec2_subnet_id              = module.dev_network.public_subnet_ids[0]
  ec2_vpc_security_group_ids = [aws_security_group.dev_sg.id]

  ec2_key_pair_name    = "vitali_key"
  ec2_private_key_path = var.path_to_local_key

  # Specify user_data startup script
  ec2_cloud_init_file_path        = var.path_to_cloud_config_file
  ec2_user_data_replace_on_change = true
}

#---------------------------------------------------------
# add security group for ec2 instance (open 22 & 80 ports)
#---------------------------------------------------------
resource "aws_security_group" "dev_sg" {
  name   = "${var.environment}-ec2-sg"
  vpc_id = module.dev_network.vpc_id

  dynamic "ingress" {
    for_each = [80, 22]
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = [0]
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
