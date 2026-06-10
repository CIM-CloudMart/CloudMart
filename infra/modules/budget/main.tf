# ==================== AWS Budgets Module ====================

resource "aws_budgets_budget" "monthly_budget" {
  name              = "${var.project}-monthly-budget-${var.environment}"
  budget_type       = "COST"
  limit_amount      = var.limit_amount
  limit_unit        = var.limit_unit
  time_unit         = "MONTHLY"
  time_period_start = "2026-06-01_00:00"

  dynamic "notification" {
    for_each = length(var.subscriber_emails) > 0 ? [1] : []
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 80
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.subscriber_emails
    }
  }

  dynamic "notification" {
    for_each = length(var.subscriber_emails) > 0 ? [1] : []
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 100
      threshold_type             = "PERCENTAGE"
      notification_type          = "FORECASTED"
      subscriber_email_addresses = var.subscriber_emails
    }
  }
}
