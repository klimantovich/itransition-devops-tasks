output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable"
  value       = aws_instance.this.public_ip
}

output "id" {
  description = "The ID of the instance"
  value       = aws_instance.this.id
}

output "instance_state" {
  description = "The state of the instance"
  value       = aws_instance.this.instance_state
}

output "public_dns" {
  description = "The public DNS name assigned to the instance."
  value       = aws_instance.this.public_dns
}
