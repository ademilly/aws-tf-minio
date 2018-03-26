data aws_ami ubuntu {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*16.04-amd64-server-*20170307"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource aws_instance minio {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.security_group_ids}"]
  subnet_id              = "${var.aws_subnet_id}"
  iam_instance_profile   = "${var.iam_instance_profile}"

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.volume_size}"
  }

  tags {
    Name = "${var.instance_name}"
  }

  user_data = "${data.template_file.user_data.rendered}"
}

data template_file user_data {
  template = "${file("${path.module}/deploy.sh")}"

  vars {
    domain = "${var.subdomain}.${var.domain}"
    email  = "${var.email}"
  }
}
