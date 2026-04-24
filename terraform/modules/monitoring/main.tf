resource "aws_sns_topic" "alerts" {
  name = "${var.project}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

locals {
  alb_suffix = split(":", var.alb_arn)[5]
}

resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name          = "${var.project}-api-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "p99"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    LoadBalancer = local.alb_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "worker_queue_depth" {
  alarm_name          = "${var.project}-worker-queue-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 10000
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    QueueName = var.sqs_queue_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    DBInstanceIdentifier = var.rds_id
  }
}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${var.project}-redis-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    CacheClusterId = var.redis_id
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.project}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    LoadBalancer = local.alb_suffix
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.project
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "API Response Time (p99)"
          metrics = [["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", local.alb_suffix, { stat = "p99" }]]
          period = 60
          region = var.aws_region
        }
      },
      {
        type = "metric"
        properties = {
          title  = "Worker Queue Depth"
          metrics = [["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.sqs_queue_name]]
          period = 60
          region = var.aws_region
        }
      },
      {
        type = "metric"
        properties = {
          title  = "RDS CPU"
          metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_id]]
          period = 60
          region = var.aws_region
        }
      },
      {
        type = "metric"
        properties = {
          title  = "Redis Memory Usage %"
          metrics = [["AWS/ElastiCache", "DatabaseMemoryUsagePercentage", "CacheClusterId", var.redis_id]]
          period = 60
          region = var.aws_region
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ALB 5xx Errors"
          metrics = [["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", local.alb_suffix]]
          period = 60
          region = var.aws_region
        }
      }
    ]
  })
}
