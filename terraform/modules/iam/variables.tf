variable "project" {}
variable "aws_region" {}
variable "sqs_arn" {}
variable "ecr_arns" { type = list(string) }
variable "github_org" {}
variable "github_repo" {}
