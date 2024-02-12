output "ec2_ssh_example" {
  value = "ssh -i ${var.path_to_local_key} ec2-user@${module.dev_ec2.public_ip}"
}
