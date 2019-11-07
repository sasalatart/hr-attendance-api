provider "aws" {
  version = "~> 2.0"
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-runahr"
    key    = "tf-state"
  }
}

module "networking" {
  source = "./networking"

  aws_common_tags = "${var.aws_common_tags}"
}

module "compute" {
  source = "./compute"

  aws_common_tags    = "${var.aws_common_tags}"
  docker_credentials = "${var.docker_credentials}"
  sg                 = "${module.networking.sg}"
}
