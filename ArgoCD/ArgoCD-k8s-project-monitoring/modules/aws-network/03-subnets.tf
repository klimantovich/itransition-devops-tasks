# Request available AZs
data "aws_availability_zones" "available_zones" { state = "available" }

# Offsets for automatic generate subnets CIDRs
locals {
  public_subnets_offset  = 1
  private_subnets_offset = local.public_subnets_offset + var.public_subnet_count
}

resource "aws_subnet" "public_subnet" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + local.public_subnets_offset)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + local.private_subnets_offset)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
  }
}
