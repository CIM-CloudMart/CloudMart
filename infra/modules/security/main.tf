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
