variable "project" {}
variable "environment" { default = "production" }
variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "aws_region" { default = "eu-west-2" }
variable "api_image" {}
variable "worker_image" {}
variable "dashboard_image" {}
variable "api_task_role_arn" {}
variable "worker_task_role_arn" {}
variable "dashboard_task_role_arn" {}
variable "execution_role_arn" {}
variable "db_url" { sensitive = true }
variable "redis_url" {}
variable "sqs_queue_url" {}
variable "alb_api_tg_arn" {}
variable "alb_dashboard_tg_arn" {}
variable "alb_security_group_id" {}
