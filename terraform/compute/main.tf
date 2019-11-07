resource "aws_key_pair" "auth" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${file(var.ssh_public_key_path)}"
}

data "aws_ami" "runahr" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*-x86_64-gp2"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.tpl")}"

  vars = {
    docker_password = "${var.docker_credentials["password"]}"
    docker_username = "${var.docker_credentials["username"]}"
  }
}

resource "aws_instance" "runahr" {
  ami                    = "${data.aws_ami.runahr.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.auth.id}"
  tags                   = "${var.aws_common_tags}"
  user_data              = "${data.template_file.user_data.rendered}"
  vpc_security_group_ids = ["${var.sg}"]

  credit_specification {
    cpu_credits = "standard"
  }
}

resource "aws_eip" "runahr" {
  instance = "${aws_instance.runahr.id}"
  tags     = "${var.aws_common_tags}"
}
