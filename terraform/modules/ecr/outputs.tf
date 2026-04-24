output "api_repository_url" {
  value = aws_ecr_repository.repos["api"].repository_url
}

output "worker_repository_url" {
  value = aws_ecr_repository.repos["worker"].repository_url
}

output "dashboard_repository_url" {
  value = aws_ecr_repository.repos["dashboard"].repository_url
}

output "repository_arns" {
  value = [for r in aws_ecr_repository.repos : r.arn]
}
