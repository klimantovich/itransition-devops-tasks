resource "aws_eip" "nat_eip" {
  count = var.public_subnet_count

  domain = "vpc"

  tags = {
    Name = "${var.environment}-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = var.public_subnet_count

  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  tags = {
    Name = "${var.environment}-nat-gateway-${count.index + 1}"
  }
}
