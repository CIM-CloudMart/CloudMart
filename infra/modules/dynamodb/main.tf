# ==================== DynamoDB Module ====================

resource "aws_dynamodb_table" "products" {
  name         = "${var.project}-products-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = var.environment == "prod"
  }

  tags = {
    Name        = "${var.project}-products-${var.environment}"
    Project     = var.project
    Environment = var.environment
    Team        = var.team
  }
}

resource "aws_dynamodb_table" "processed_events" {
  name         = "${var.project}-processed-events-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = var.environment == "prod"
  }

  tags = {
    Name        = "${var.project}-processed-events-${var.environment}"
    Project     = var.project
    Environment = var.environment
    Team        = var.team
  }
}
