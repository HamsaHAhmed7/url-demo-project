output "api_task_role_arn" {
  value = aws_iam_role.api.arn
}

output "worker_task_role_arn" {
  value = aws_iam_role.worker.arn
}

output "dashboard_task_role_arn" {
  value = aws_iam_role.dashboard.arn
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
