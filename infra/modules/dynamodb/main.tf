# ==================== DynamoDB Module ====================

resource "aws_dynamodb_table" "products" {
  name         = "${var.project}-products-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
