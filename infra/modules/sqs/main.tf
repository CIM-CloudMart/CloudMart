# ==================== SQS Module ====================

resource "aws_sqs_queue" "order_events" {
  name = "${var.project}-order-events-${var.environment}"
}
