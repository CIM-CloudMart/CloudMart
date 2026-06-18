variable "services" {
  description = "List of services to create log groups for"
  type        = list(string)
  default     = ["frontend", "product-service", "order-service", "user-service", "notification-service"]
}

resource "aws_cloudwatch_log_group" "service_logs" {
  for_each          = toset(var.services)
  name              = "/cloudmart/${each.key}-${var.environment}"
  retention_in_days = 7

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

data "aws_region" "current" {}

# ==================== Application Alerting & Metrics ====================

resource "aws_sns_topic" "alerts" {
  name = "${var.project}-alerts-${var.environment}"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "alerts_email" {
  count     = length(var.subscriber_emails) > 0 ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.subscriber_emails[0]
}

# Metric filter to track requests
resource "aws_cloudwatch_log_metric_filter" "product_service_requests" {
  name           = "${var.project}-product-requests-${var.environment}"
  pattern        = ""
  log_group_name = aws_cloudwatch_log_group.service_logs["product-service"].name

  metric_transformation {
    name      = "RequestCount"
    namespace = "CloudMart/product-service-${var.environment}"
    value     = "1"
  }
}

# Metric filter to track errors
resource "aws_cloudwatch_log_metric_filter" "product_service_errors" {
  name           = "${var.project}-product-errors-${var.environment}"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.service_logs["product-service"].name

  metric_transformation {
    name      = "ErrorCount"
    namespace = "CloudMart/product-service-${var.environment}"
    value     = "1"
  }
}

# Alarm for product service error rate
resource "aws_cloudwatch_metric_alarm" "product_service_high_error_rate" {
  alarm_name          = "${var.project}-product-service-high-error-rate-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 5
  alarm_description   = "Alarm when product-service error rate exceeds 5% over 5 minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  metric_query {
    id          = "error_rate"
    expression  = "errors / requests * 100"
    label       = "Error Rate (%)"
    return_data = true
  }

  metric_query {
    id = "errors"
    metric {
      metric_name = "ErrorCount"
      namespace   = "CloudMart/product-service-${var.environment}"
      period      = 300
      stat        = "Sum"
    }
  }

  metric_query {
    id = "requests"
    metric {
      metric_name = "RequestCount"
      namespace   = "CloudMart/product-service-${var.environment}"
      period      = 300
      stat        = "Sum"
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Alarm for SQS queue depth
resource "aws_cloudwatch_metric_alarm" "sqs_queue_depth" {
  alarm_name          = "${var.project}-sqs-queue-depth-high-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 100
  alarm_description   = "Alarm when SQS queue depth exceeds 100 messages for 5 minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    QueueName = var.sqs_queue_name
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# ==================== CloudWatch Dashboard ====================

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project}-dashboard-${var.environment}"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "# 🛒 CloudMart - ${upper(var.environment)} Operations Dashboard"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ { "expression" = "SEARCH('{ContainerInsights,ClusterName,Namespace,PodName} ClusterName=\"${var.project}\" Namespace=\"cloudmart-${var.environment}\" pod_cpu_utilization', 'Average', 300)", "id" = "e1" } ]
          ],
          period = 300,
          region = data.aws_region.current.region,
          title  = "Pod CPU Utilization (%) per Service"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ { "expression" = "SEARCH('{ContainerInsights,ClusterName,Namespace,PodName} ClusterName=\"${var.project}\" Namespace=\"cloudmart-${var.environment}\" pod_memory_utilization', 'Average', 300)", "id" = "e2" } ]
          ],
          period = 300,
          region = data.aws_region.current.region,
          title  = "Pod Memory Utilization (%) per Service"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.sqs_queue_name]
          ],
          period = 300,
          stat   = "Maximum",
          region = data.aws_region.current.region,
          title  = "SQS Queue Depth (Order Events)"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 8
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "cloudmart-postgres-${var.environment}"]
          ],
          period = 300,
          stat   = "Average",
          region = data.aws_region.current.region,
          title  = "RDS Database Connections"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 8
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", "cloudmart-products-${var.environment}"],
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", "cloudmart-products-${var.environment}"]
          ],
          period = 300,
          stat   = "Sum",
          region = data.aws_region.current.region,
          title  = "DynamoDB Consumed Throughput"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 14
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["CloudMart", "orders_processed_total", "Environment", var.environment, "Service", "order-service"]
          ],
          period = 300,
          stat   = "Sum",
          region = data.aws_region.current.region,
          title  = "Orders Processed (Custom EMF Metric)"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 14
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["CloudMart/product-service-${var.environment}", "ErrorCount"]
          ],
          period = 300,
          stat   = "Sum",
          region = data.aws_region.current.region,
          title  = "Product Service Errors (Metric Filter)"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 20
        width  = 24
        height = 6
        properties = {
          query  = "SOURCE '/aws/vpc-flow-log/cloudmart-${var.environment}' | filter action = 'REJECT' | stats count(*) by srcAddr, dstAddr, dstPort | sort count(*) desc | limit 20",
          region = data.aws_region.current.region,
          title  = "Rejected VPC Flow Logs (Top Sources & Ports)"
        }
      }
    ]
  })

  depends_on = [aws_cloudwatch_log_group.service_logs]
}


# Alarms and more detailed dashboards should be added per service integration
