output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "task_security_group_id" {
  value = aws_security_group.tasks.id
}
