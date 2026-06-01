output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS PostgreSQL endpoint"
}

output "rds_db_name" {
  value       = aws_db_instance.postgres.db_name
  description = "RDS PostgreSQL database name"
}
