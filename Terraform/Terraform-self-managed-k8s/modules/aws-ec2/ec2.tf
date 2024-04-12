terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#----------------------------------------
# Instance
#----------------------------------------
resource "aws_instance" "this" {

  # Application and OS Images (Amazon Machine Image) 
  ami = var.ec2_ami

  # Instance type
  instance_type = var.ec2_instance_type

  # Key pair (login)
  key_name = var.ec2_key_name

  # Network settings 
  associate_public_ip_address = var.ec2_associate_public_ip_address
  availability_zone           = var.ec2_availability_zone
  subnet_id                   = var.ec2_subnet_id
  vpc_security_group_ids      = var.ec2_vpc_security_group_ids
  iam_instance_profile        = var.ec2_iam_instance_profile
  private_ip                  = var.ec2_private_ip

  # Configure storage
  root_block_device {
    delete_on_termination = var.ec2_delete_on_termination
    volume_size           = var.ec2_volume_size
  }

  # Advanced details
  user_data_replace_on_change = var.ec2_user_data_replace_on_change
  user_data                   = var.ec2_cloud_init_file_path != null ? data.cloudinit_config.userdata[0].rendered : var.ec2_user_data
  user_data_base64            = var.ec2_user_data_base64

  tags = var.ec2_instance_tags
}

#----------------------------------------
# Cloud-init config
#----------------------------------------
data "cloudinit_config" "userdata" {
  count = var.ec2_cloud_init_file_path != null ? 1 : 0

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = file(var.ec2_cloud_init_file_path)
  }
}
