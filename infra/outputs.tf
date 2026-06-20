output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.waf.web_acl_arn
}

output "user_jwt_role_arn" {
  description = "The ARN of the IAM role for user-service JWT key reader"
  value       = module.iam.user_jwt_role_arn
}

output "keda_operator_role_arn" {
  description = "The ARN of the IAM role for KEDA operator"
  value       = module.iam.keda_operator_role_arn
}

