output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.core.waf_web_acl_arn
}

output "user_jwt_role_arn" {
  description = "The ARN of the IAM role for user-service JWT key reader"
  value       = module.core.user_jwt_role_arn
}
