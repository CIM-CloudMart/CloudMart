output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS Cluster Name"
}

output "eks_oidc_provider_url" {
  value       = module.eks.oidc_provider_url
  description = "EKS OIDC Provider URL"
}

output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "RDS PostgreSQL endpoint"
}

output "dynamodb_table_name" {
  value       = module.dynamodb.dynamodb_table_name
  description = "DynamoDB products table name"
}

output "storage_bucket_name" {
  value       = module.s3.bucket_name
  description = "S3 storage bucket name"
}

output "sqs_queue_url" {
  value       = module.sqs.queue_url
  description = "SQS queue URL"
}

output "product_service_role_arn" {
  value       = module.iam.product_service_role_arn
  description = "IAM Role ARN for product-service"
}

output "order_service_role_arn" {
  value       = module.iam.order_service_role_arn
  description = "IAM Role ARN for order-service"
}

output "notification_service_role_arn" {
  value       = module.iam.notification_service_role_arn
  description = "IAM Role ARN for notification-service"
}

output "user_service_role_arn" {
  value       = module.iam.user_service_role_arn
  description = "IAM Role ARN for user-service"
}

output "web_acl_arn" {
  value       = module.waf.web_acl_arn
  description = "The ARN of the WAF Web ACL"
}

output "github_actions_role_arn" {
  value       = module.iam.github_actions_role_arn
  description = "The ARN of the GitHub Actions IAM role"
}

