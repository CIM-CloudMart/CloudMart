# ==================== KMS Module ====================

resource "aws_kms_key" "main" {
  description             = "KMS key for CloudMart ${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.project}-kms-key-${var.environment}"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project}-key-${var.environment}"
  target_key_id = aws_kms_key.main.key_id
}
