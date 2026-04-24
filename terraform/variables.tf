variable "aws_region" {
  default = "eu-west-2"
}

variable "project" {
  default = "project-demo"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email for CloudWatch alarm notifications"
  type        = string
}

variable "github_org" {
  description = "GitHub org or username for OIDC trust"
  default     = "HamsaHAhmed7"
}

variable "github_repo" {
  description = "GitHub repo name for OIDC trust"
  default     = "project-demo"
}
