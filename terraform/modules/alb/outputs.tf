output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "api_target_group_arn" {
  value = aws_lb_target_group.api.arn
}

output "dashboard_target_group_arn" {
  value = aws_lb_target_group.dashboard.arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}
