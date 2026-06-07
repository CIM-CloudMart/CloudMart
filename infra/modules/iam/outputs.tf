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

output "aws_load_balancer_controller_role_arn" {
  value       = aws_iam_role.aws_load_balancer_controller.arn
  description = "The ARN of the IAM role for AWS Load Balancer Controller"
}
