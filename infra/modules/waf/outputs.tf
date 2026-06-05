output "web_acl_arn" {
  value       = try(aws_wafv2_web_acl.main[0].arn, null)
  description = "The ARN of the WAF Web ACL"
}

output "web_acl_id" {
  value       = try(aws_wafv2_web_acl.main[0].id, null)
  description = "The ID of the WAF Web ACL"
}

