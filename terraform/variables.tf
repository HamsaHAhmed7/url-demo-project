variable "aws_region" {
  default = "eu-west-2"
}

variable "environment" {
  description = "Deployment environment"
  default     = "production"
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
  default     = "url-demo-project"
}

variable "root_domain" {
  description = "Root Route53 domain (must already exist in your AWS account)"
  default     = "hamsa-ahmed.co.uk"
}

variable "subdomain" {
  description = "Full subdomain for the URL shortener"
  default     = "url.hamsa-ahmed.co.uk"
}
