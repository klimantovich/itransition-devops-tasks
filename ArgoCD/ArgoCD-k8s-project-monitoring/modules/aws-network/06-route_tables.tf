### Route Tables
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-public-route-table"
  }

}

resource "aws_route_table" "private" {
  count = var.private_subnet_count

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-private-route-table-${count.index + 1}"
  }
}


### Routes
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.private_subnet_count
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}


### Route table assiciations
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count

  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = var.public_subnet_count

  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
