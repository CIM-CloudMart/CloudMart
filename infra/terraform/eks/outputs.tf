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


output "aws_load_balancer_controller_role_arn" {
  value       = module.iam_prod.aws_load_balancer_controller_role_arn
  description = "IAM Role ARN for AWS Load Balancer Controller"
}

# ==================== Prod Outputs ====================


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
