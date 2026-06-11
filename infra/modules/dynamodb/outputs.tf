output "dynamodb_table_name" {
  value       = aws_dynamodb_table.products.name
  description = "The name of the DynamoDB products table"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.products.arn
  description = "The ARN of the DynamoDB products table"
}

output "dynamodb_events_table_arn" {
  value       = aws_dynamodb_table.processed_events.arn
  description = "The ARN of the DynamoDB processed events table"
}

