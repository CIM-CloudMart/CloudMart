output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.core.waf_web_acl_arn
}
