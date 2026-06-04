# ==================== SQS Module ====================

resource "aws_sqs_queue" "order_events" {
  name                       = "${var.project}-order-events-${var.environment}"
  sqs_managed_sse_enabled    = var.kms_key_id == null
  kms_master_key_id          = var.kms_key_id
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = 1209600 # 14 days

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_events_dlq.arn
    maxReceiveCount     = var.redrive_max_receive_count
  })

  tags = {
    Name        = "${var.project}-order-events-${var.environment}"
    Project     = var.project
    Environment = var.environment
    Team        = var.team
  }
}

resource "aws_sqs_queue" "order_events_dlq" {
  name                      = "${var.project}-order-events-dlq-${var.environment}"
  sqs_managed_sse_enabled   = var.kms_key_id == null
  kms_master_key_id         = var.kms_key_id
  message_retention_seconds = 1209600

  tags = {
    Name        = "${var.project}-order-events-dlq-${var.environment}"
    Project     = var.project
    Environment = var.environment
    Team        = var.team
  }
}
