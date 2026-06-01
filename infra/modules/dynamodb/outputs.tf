output "dynamodb_table_name" {
  value       = aws_dynamodb_table.products.name
  description = "The name of the DynamoDB products table"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.products.arn
  description = "The ARN of the DynamoDB products table"
}
