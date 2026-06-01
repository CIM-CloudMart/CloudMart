# ==================== ECR Module ====================

resource "aws_ecr_repository" "repos" {
  for_each             = toset(var.repository_names)
  name                 = "${var.project}-${each.key}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256" # Default KMS/AES encryption
  }

  tags = {
    Name = "${var.project}-${each.key}-${var.environment}"
  }
}
