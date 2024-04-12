#----------------------------------------
# EC2 instance variables
#----------------------------------------
variable "ec2_ami" {
  description = "AMI to use for the instance (REQUIRED)"
  type        = string
}

variable "ec2_associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = null
}

variable "ec2_availability_zone" {
  description = "AZ to start the instance in"
  type        = string
  default     = null
}

variable "ec2_instance_type" {
  description = "Instance type to use for the instance"
  type        = string
}

variable "ec2_key_name" {
  description = "Name Key name of the Key Pair to use for the instance"
  type        = string
  default     = null
}

variable "ec2_subnet_id" {
  description = "VPC Subnet ID to launch in."
  type        = string
  default     = null
}

variable "ec2_private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable "ec2_vpc_security_group_ids" {
  description = "List of security group names to associate with"
  type        = list(string)
  default     = null
}

variable "ec2_iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with"
  type        = string
  default     = null
}

variable "ec2_delete_on_termination" {
  type    = bool
  default = null
}

variable "ec2_volume_size" {
  type    = number
  default = null
}

variable "ec2_instance_tags" {
  description = "Key-value pairs of metadata tags for ec2 instance"
  type        = map(string)
  default     = {}
}

#----------------------------------------
# User_data / cloud-init
#----------------------------------------
variable "ec2_user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead"
  type        = string
  default     = null
}

variable "ec2_user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption"
  type        = string
  default     = null
}

variable "ec2_cloud_init_file_path" {
  description = "The user data to provide when launching the instance. File path. Set if you want to provide user-data. Conflicts with e2_user_data variable"
  type        = string
  default     = null
}

variable "ec2_user_data_replace_on_change" {
  description = "When used in combination with user_data will trigger a destroy and recreate when set to true. Defaults to false if not set."
  type        = bool
  default     = null
}

