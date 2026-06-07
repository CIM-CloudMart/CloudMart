output "secret_arn" {
  value       = aws_secretsmanager_secret.db.arn
  description = "ARN of the created secretsmanager secret"
  depends_on  = [aws_secretsmanager_secret_version.db]
}

output "secret_id" {
  value       = aws_secretsmanager_secret.db.id
  description = "ID of the created secretsmanager secret"
  depends_on  = [aws_secretsmanager_secret_version.db]
}

output "jwt_secret_arn" {
  value       = aws_secretsmanager_secret.jwt.arn
  description = "ARN of the created JWT secretsmanager secret"
  depends_on  = [aws_secretsmanager_secret_version.jwt]
}

output "jwt_secret_name" {
  value       = aws_secretsmanager_secret.jwt.name
  description = "Name of the created JWT secretsmanager secret"
}

output "db_password" {
  value       = random_password.db_password.result
  description = "The generated database password"
  sensitive   = true
}

output "db_username" {
  value       = var.username
  description = "The database username"
}
