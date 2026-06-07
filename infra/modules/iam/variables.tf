variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "oidc_url" {
  description = "EKS OIDC Provider URL"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "DynamoDB table ARN for products"
  type        = string
}

variable "sqs_queue_arn" {
  description = "SQS queue ARN for order events"
  type        = string
}

variable "storage_bucket_arn" {
  description = "S3 storage bucket ARN"
  type        = string
}

variable "ses_email_identity_arn" {
  description = "SES verified email identity ARN"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for RDS credentials (user-service IRSA)"
  type        = string
}

variable "jwt_secret_arn" {
  description = "Secrets Manager ARN for JWT Secret (user-service IRSA)"
  type        = string
}


