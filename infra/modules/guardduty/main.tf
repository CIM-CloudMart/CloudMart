resource "aws_guardduty_detector" "main" {
  enable = true

  finding_publishing_frequency = "SIX_HOURS"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
