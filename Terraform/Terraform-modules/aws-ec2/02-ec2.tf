resource "aws_instance" "this" {

  # Application and OS Images (Amazon Machine Image) 
  ami = var.ec2_ami

  # Instance type
  instance_type = var.ec2_instance_type

  # Key pair (login)
  key_name = aws_key_pair.this.key_name

  # Network settings 
  associate_public_ip_address = var.ec2_associate_public_ip_address
  availability_zone           = var.ec2_availability_zone
  subnet_id                   = var.ec2_subnet_id
  vpc_security_group_ids      = var.ec2_vpc_security_group_ids

  # Configure storage
  root_block_device {
    delete_on_termination = var.ec2_delete_on_termination
    volume_size           = var.ec2_volume_size
  }

  # Advanced details
  user_data_replace_on_change = var.ec2_user_data_replace_on_change
  user_data                   = var.ec2_cloud_init_file_path != null ? data.cloudinit_config.userdata[0].rendered : ""
}

#------------------
# Cloud-init config
#------------------
data "cloudinit_config" "userdata" {
  count = var.ec2_cloud_init_file_path != null ? 1 : 0

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = file(var.ec2_cloud_init_file_path)
  }
}

#-----------------
# Generate rsa key
#-----------------
resource "aws_key_pair" "this" {
  key_name   = var.ec2_key_pair_name
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "rsa_key" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = var.ec2_private_key_path
  file_permission = "400"
}
