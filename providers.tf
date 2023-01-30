terraform {

  required_version = "= 1.3.7"

  #  required_providers {
  #    aws = {
  #      source  = "hashicorp/aws"
  #      version = "~> 4.52.0"
  #    }
  #  }
}

provider "aws" {
  region = var.region
  #  assume_role {
  #    role_arn = var.role_arn
  #  }
}
