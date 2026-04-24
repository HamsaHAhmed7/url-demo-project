output "connection_url" {
  value     = "postgresql://app:${var.db_password}@${aws_db_instance.postgres.endpoint}/shortener"
  sensitive = true
}

output "instance_id" {
  value = aws_db_instance.postgres.id
}
