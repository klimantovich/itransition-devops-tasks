locals {
  # Decide whether to create custom subnet groups (if the necessary variables are set)
  create_subnet_group = length(var.subnet_group_subnet_ids) > 0 ? true : false
}

#-----------------------------------------------
# DB instance configuration
#-----------------------------------------------
resource "aws_db_instance" "default" {

  allocated_storage      = var.replicate_source_db != null ? null : var.db_allocated_storage
  apply_immediately      = var.db_apply_immediately
  availability_zone      = var.db_multi_az ? null : var.db_availability_zone
  ca_cert_identifier     = var.db_ca_cert_identifier
  db_name                = var.database_name
  db_subnet_group_name   = local.create_subnet_group ? join("", aws_db_subnet_group.default[*].name) : null
  engine                 = var.replicate_source_db != null ? null : var.db_engine
  engine_version         = var.replicate_source_db != null ? null : var.db_engine_version
  identifier             = var.db_identifier
  instance_class         = var.db_instance_class
  multi_az               = var.db_multi_az
  password               = var.replicate_source_db != null ? null : var.db_password
  publicly_accessible    = var.db_publicly_accessible
  replicate_source_db    = var.replicate_source_db
  skip_final_snapshot    = var.db_skip_final_snapshot
  username               = var.replicate_source_db != null ? null : var.db_username
  vpc_security_group_ids = [aws_security_group.db.id]

  depends_on = [aws_db_subnet_group.default, aws_security_group.db]

}

#-----------------------------------------------
# Security group for DB
#-----------------------------------------------
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Inbound traffic for db servers"
  vpc_id      = var.security_group_vpc_id

  dynamic "ingress" {
    for_each = [
      { cidr_blocks = var.db_ingress_cidr_blocks, security_groups = null },
      { cidr_blocks = null, security_groups = var.db_ingress_security_group_ids }
    ]
    content {
      from_port       = var.security_group_db_port
      to_port         = var.security_group_db_port
      protocol        = "tcp"
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = [0]
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "${var.environment}-db-sg"
  }
}

#-----------------------------------------------
# Subnet group for DB
#-----------------------------------------------
resource "aws_db_subnet_group" "default" {
  count = local.create_subnet_group ? 1 : 0

  name        = var.subnet_group_name
  description = var.subnet_group_description
  subnet_ids  = var.subnet_group_subnet_ids
}
