variable "aws_common_tags" {
  type = "map"

  default = {
    Name = "runahr"
  }
}

variable "docker_credentials" {
  type = "map"
}
