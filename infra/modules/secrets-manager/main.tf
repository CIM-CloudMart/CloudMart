resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "@-_."
}

# Create Secrets Manager secret and initial version
resource "aws_secretsmanager_secret" "db" {
  name        = "${var.project}-${var.secret_name}-${var.environment}"
  description = "Database credentials for ${var.project} (${var.environment})"
  kms_key_id  = var.kms_key_id

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.db_password.result
  })
}

# Rotation placeholder: user must attach a Lambda for automatic rotation if desired