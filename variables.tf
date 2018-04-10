variable subdomain {
  description = "Subdomain name string"
}

variable domain {
  description = "Domain name string"
}

variable email {
  description = "Email used for certificate generation"
}

variable aws_vpc_id {
  description = "VPC ID"
}

variable aws_subnet_id {
  description = "Subnet ID"
}

# EC2 keys block
variable key_name {
  description = "EC2 Key name"
}

variable instance_name {
  description = "EC2 Instance name metadata"
}

variable volume_size {
  description = "EC2 root volume size"
  default     = 128
}

variable instance_type {
  description = "EC2 instance type"
  default     = "t2.nano"
}

variable iam_instance_profile {
  description = "EC2 IAM instance profile name"
  default     = ""
}

# Security group block
variable security_group_ids {
  type        = "list"
  description = "AWS security group IDs"
}

# Route 53 block
variable zone_id {
  description = "Route 53 zone ID"
}

# S3 block
variable bucket {
  description = "S3 bucket with which to synchronize"
}
