# Terraform Minio module for AWS

Package a Minio (https://www.minio.io) terraform module for AWS
- deploy a Minio docker image on an ec2 machine with https enabled through nginx
- spin up a route53 record to the ec2 machine 

## Usage

main.tf
```
module minio {
  source = "github.com/ademilly/aws-tf-minio"

  subdomain          = "minio"
  domain             = "mydomain.com"
  email              = "some_adress@some.where"
  aws_vpc_id         = "${data.aws_vpc.main.id}"
  aws_subnet_id      = "${data.aws_subnet.main.id}"
  key_name           = "${var.key_name}"
  instance_name      = "SOME INSTANCE NAME"
  security_group_ids = ["${aws_security_group.minio.id}", ...]
  zone_id            = "${data.aws_route53_zone.main.id}"
}
```

## Variables


```
    $ cat variables.tf
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

# Security group block
variable security_group_ids {
  type        = "list"
  description = "AWS security group IDs"
}

# Route 53 block
variable zone_id {
  description = "Route 53 zone ID"
}
```
