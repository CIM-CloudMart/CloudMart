# ==================== ECR Module ====================

resource "aws_ecr_repository" "repos" {
  for_each             = toset(var.repository_names)
  name                 = "${var.project}-${each.key}-${var.environment}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = var.kms_key_id != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_id
  }

  tags = {
    Name        = "${var.project}-${each.key}-${var.environment}"
    Project     = var.project
    Environment = var.environment
    Team        = var.team
    Owner       = var.owner_email
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  for_each   = aws_ecr_repository.repos
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire images beyond latest 10"
        selection = {
          tagStatus  = "any"
          countType  = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  depends_on = [aws_ecr_repository.repos]
}
