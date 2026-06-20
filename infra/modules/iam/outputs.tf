output "product_service_role_arn" {
  value       = aws_iam_role.product_service.arn
  description = "The ARN of the IAM role for product-service"
}

output "order_service_role_arn" {
  value       = aws_iam_role.order_service.arn
  description = "The ARN of the IAM role for order-service"
}

output "notification_service_role_arn" {
  value       = aws_iam_role.notification_service.arn
  description = "The ARN of the IAM role for notification-service"
}

output "user_service_role_arn" {
  value       = aws_iam_role.user_service.arn
  description = "The ARN of the IAM role for user-service"
}

output "user_jwt_role_arn" {
  value       = aws_iam_role.user_jwt.arn
  description = "The ARN of the IAM role for user-service JWT key reader"
}

output "aws_load_balancer_controller_role_arn" {
  value       = aws_iam_role.aws_load_balancer_controller.arn
  description = "The ARN of the IAM role for AWS Load Balancer Controller"
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "The ARN of the IAM role for GitHub Actions"
}

output "adot_collector_role_arn" {
  value       = aws_iam_role.adot_collector.arn
  description = "The ARN of the IAM role for ADOT Collector"
}

output "cloudwatch_observability_role_arn" {
  value       = aws_iam_role.cloudwatch_observability.arn
  description = "The ARN of the IAM role for CloudWatch Observability addon"
}

output "keda_operator_role_arn" {
  value       = aws_iam_role.keda_operator.arn
  description = "The ARN of the IAM role for KEDA operator"
}



