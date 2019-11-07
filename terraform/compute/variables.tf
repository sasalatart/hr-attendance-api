variable "aws_common_tags" {
  type = "map"
}

variable "docker_credentials" {
  type = "map"
}

variable "instance_type" {
  default = "t3.nano"
}

variable "ssh_key_name" {
  default = "runahr"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "sg" {}
