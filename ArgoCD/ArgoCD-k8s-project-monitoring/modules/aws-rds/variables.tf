#-----------------------------------------------
# Common variables
#-----------------------------------------------
variable "environment" {
  description = "Environment prefix for AWS RDS resources"
  type        = string
  default     = ""
}

#-----------------------------------------------
# Database instance variables
#-----------------------------------------------
variable "db_allocated_storage" {
  description = "(Required unless a replicate_source_db is provided) The allocated storage in gibibytes"
  type        = number
  default     = null
  validation {
    condition     = var.db_allocated_storage > 0
    error_message = "Allocated storage should be > 0 Gb."
  }
}

variable "db_apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is false"
  type        = bool
  default     = false
}

variable "db_availability_zone" {
  description = "The AZ for the RDS instance"
  type        = string
  default     = null
}

variable "db_ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "database_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = null
}

variable "db_engine_version" {
  description = "The database engine to use (https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html)"
  type        = string
  default     = null
}

variable "db_engine" {
  description = "The engine version to use"
  type        = string
  default     = null
}

variable "db_identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
  type        = string
  default     = null
}

variable "db_instance_class" {
  description = "(Required) The instance type of the RDS instance (example: db.t3.micro)"
  type        = string
  default     = null
  validation {
    condition     = can(regex("db.[a-z]+", var.db_instance_class))
    error_message = "Instance class name should begin from db (db.t3.micro etc)"
  }
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "db_password" {
  description = "Required unless replicate_source_db is provided.) Password for the master DB user"
  type        = string
  sensitive   = true
  default     = null
}

variable "db_publicly_accessible" {
  description = "Bool to control if instance is publicly accessible. Default is false"
  type        = bool
  default     = false
}

variable "replicate_source_db" {
  description = "Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the identifier of another Amazon RDS Database to replicate"
  type        = string
  default     = null
}

variable "db_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created"
  type        = bool
  default     = false
}

variable "db_username" {
  description = "(Required unless replicate_source_db is provided) Username for the master DB user. Cannot be specified for a replica."
  type        = string
  default     = null
}

#-----------------------------------------------
# Security group variables
#-----------------------------------------------
variable "security_group_vpc_id" {
  description = "ID of VPC where DB is allocated"
  type        = string
  default     = null
}

variable "security_group_db_port" {
  description = "DB port for security groups (like 3306 for mysql etc.)"
  type        = number
  default     = null
}

variable "db_ingress_cidr_blocks" {
  description = "CIDR blocks, from where inbound traffic to DB are allowed"
  type        = list(string)
  default     = []
}

variable "db_ingress_security_group_ids" {
  description = "IDs of security groups from where ingress traffic are allowed"
  type        = list(string)
  default     = []
}

#-----------------------------------------------
# Subnet group variables
#-----------------------------------------------
variable "subnet_group_name" {
  description = "The name of the DB subnet group. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "subnet_group_description" {
  description = "The description of the DB subnet group. Defaults to \"Managed by Terraform\"."
  type        = string
  default     = null
}

variable "subnet_group_subnet_ids" {
  description = "(Required) A list of VPC subnet IDs where DB will be exist"
  type        = list(string)
  default     = []
}
