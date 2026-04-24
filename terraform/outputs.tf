output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "app_url" {
  value = "https://${var.subdomain}"
}

output "api_ecr_url" {
  value = module.ecr.api_repository_url
}

output "worker_ecr_url" {
  value = module.ecr.worker_repository_url
}

output "dashboard_ecr_url" {
  value = module.ecr.dashboard_repository_url
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}
