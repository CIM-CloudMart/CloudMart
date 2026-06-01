# ==================== Route 53 Module ====================

resource "aws_route53_zone" "primary" {
  name          = var.domain_name
  force_destroy = var.environment != "prod"

  tags = {
    Name        = "${var.project}-zone-${var.environment}"
    Environment = var.environment
  }
}
