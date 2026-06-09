output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS Cluster Name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS Cluster Endpoint"
}

output "cluster_ca_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "EKS Cluster Certificate Authority Data"
}

output "oidc_issuer_url" {
  value       = module.eks.oidc_provider_url
  description = "EKS OIDC Provider URL"
}

output "aws_load_balancer_controller_role_arn" {
  value       = module.iam_prod.aws_load_balancer_controller_role_arn
  description = "IAM Role ARN for AWS Load Balancer Controller"
}

# ==================== Prod Outputs ====================

output "rds_endpoint_prod" {
  value       = module.rds_prod.rds_endpoint
  description = "RDS PostgreSQL endpoint for production"
}

output "dynamodb_table_name_prod" {
  value       = module.dynamodb_prod.dynamodb_table_name
  description = "DynamoDB products table name for production"
}

output "storage_bucket_name_prod" {
  value       = module.s3_prod.bucket_name
  description = "S3 storage bucket name for production"
}

output "sqs_queue_url_prod" {
  value       = module.sqs_prod.queue_url
  description = "SQS queue URL for production"
}

output "product_service_role_arn_prod" {
  value       = module.iam_prod.product_service_role_arn
  description = "IAM Role ARN for product-service in production"
}

output "order_service_role_arn_prod" {
  value       = module.iam_prod.order_service_role_arn
  description = "IAM Role ARN for order-service in production"
}

output "notification_service_role_arn_prod" {
  value       = module.iam_prod.notification_service_role_arn
  description = "IAM Role ARN for notification-service in production"
}

output "user_service_role_arn_prod" {
  value       = module.iam_prod.user_service_role_arn
  description = "IAM Role ARN for user-service in production"
}

# ==================== Staging Outputs ====================

output "rds_endpoint_staging" {
  value       = module.rds_staging.rds_endpoint
  description = "RDS PostgreSQL endpoint for staging"
}

output "dynamodb_table_name_staging" {
  value       = module.dynamodb_staging.dynamodb_table_name
  description = "DynamoDB products table name for staging"
}

output "storage_bucket_name_staging" {
  value       = module.s3_staging.bucket_name
  description = "S3 storage bucket name for staging"
}

output "sqs_queue_url_staging" {
  value       = module.sqs_staging.queue_url
  description = "SQS queue URL for staging"
}

output "product_service_role_arn_staging" {
  value       = module.iam_staging.product_service_role_arn
  description = "IAM Role ARN for product-service in staging"
}

output "order_service_role_arn_staging" {
  value       = module.iam_staging.order_service_role_arn
  description = "IAM Role ARN for order-service in staging"
}

output "notification_service_role_arn_staging" {
  value       = module.iam_staging.notification_service_role_arn
  description = "IAM Role ARN for notification-service in staging"
}

output "user_service_role_arn_staging" {
  value       = module.iam_staging.user_service_role_arn
  description = "IAM Role ARN for user-service in staging"
}
