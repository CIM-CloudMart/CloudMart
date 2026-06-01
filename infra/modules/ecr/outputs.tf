output "repository_urls" {
  value       = { for k, v in aws_ecr_repository.repos : k => v.repository_url }
  description = "Map of service names to repository URLs"
}

output "repository_arns" {
  value       = { for k, v in aws_ecr_repository.repos : k => v.arn }
  description = "Map of service names to repository ARNs"
}
