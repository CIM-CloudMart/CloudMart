# ==================== SES Module ====================

resource "aws_ses_email_identity" "notification_email" {
  email = var.from_email
}
