output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "private_subnet_cidrs" {
  value = aws_subnet.private_subnet[*].cidr_block
}

output "public_subnet_cidrs" {
  value = aws_subnet.public_subnet[*].cidr_block
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}
