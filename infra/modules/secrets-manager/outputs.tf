output "secret_arn" {
  value       = aws_secretsmanager_secret.db.arn
  description = "ARN of the created secretsmanager secret"
}

output "secret_id" {
  value       = aws_secretsmanager_secret.db.id
  description = "ID of the created secretsmanager secret"
}
