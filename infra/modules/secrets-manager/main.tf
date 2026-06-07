resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "-_."
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

resource "random_password" "jwt_secret" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "jwt" {
  name        = "${var.project}-jwt-secret-${var.environment}"
  description = "JWT secret key for ${var.project} (${var.environment})"
  kms_key_id  = var.kms_key_id

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = random_password.jwt_secret.result
}

# Rotation placeholder: user must attach a Lambda for automatic rotation if desired