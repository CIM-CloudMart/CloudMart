# ==================== Security Module (GuardDuty) ====================
# Disabled by default on new/free-tier accounts (SubscriptionRequiredException).

resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  finding_publishing_frequency = "SIX_HOURS"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# ==================== Threat Detection Alerting ====================

resource "aws_sns_topic" "security_alerts" {
  count = var.enable_guardduty ? 1 : 0
  name  = "${var.project}-security-alerts-${var.environment}"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "security_email" {
  count     = var.enable_guardduty && length(var.subscriber_emails) > 0 ? 1 : 0
  topic_arn = aws_sns_topic.security_alerts[0].arn
  protocol  = "email"
  endpoint  = var.subscriber_emails[0]
}

# EventBridge rule for GuardDuty findings with severity >= 4
resource "aws_cloudwatch_event_rule" "guardduty" {
  count       = var.enable_guardduty ? 1 : 0
  name        = "${var.project}-guardduty-findings-${var.environment}"
  description = "Capture GuardDuty findings with severity >= 4"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [
        {
          numeric = [">=", 4]
        }
      ]
    }
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "guardduty" {
  count     = var.enable_guardduty ? 1 : 0
  rule      = aws_cloudwatch_event_rule.guardduty[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.security_alerts[0].arn
}

# Enable AWS Security Hub
resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0
}

