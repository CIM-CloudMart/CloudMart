output "web_acl_arn" {
  value       = aws_wafv2_web_acl.main.arn
  description = "The ARN of the WAF Web ACL"
}

output "web_acl_id" {
  value       = aws_wafv2_web_acl.main.id
  description = "The ID of the WAF Web ACL"
}
