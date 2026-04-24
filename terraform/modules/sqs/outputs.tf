output "queue_arn" {
  value = aws_sqs_queue.click_events.arn
}

output "queue_url" {
  value = aws_sqs_queue.click_events.url
}

output "queue_name" {
  value = aws_sqs_queue.click_events.name
}
