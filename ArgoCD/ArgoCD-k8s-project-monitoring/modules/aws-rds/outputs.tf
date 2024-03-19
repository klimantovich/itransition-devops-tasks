output "instance_id" {
  description = "Identifier of instance"
  value       = aws_db_instance.default.identifier
}

output "subnet_group_id" {
  description = "DB subnet group id"
  value       = aws_db_subnet_group.default[*].id
}

output "security_group_id" {
  description = "DB security group id"
  value       = aws_security_group.db.id
}

output "instance_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.default.address
}

output "instance_endpoint" {
  description = "Endpoint of the instance"
  value       = aws_db_instance.default.endpoint
}
