terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "project-demo-tf-state"
    key            = "production/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "project-demo-tf-locks"
  }
}

provider "aws" {
  region = var.aws_region
}
