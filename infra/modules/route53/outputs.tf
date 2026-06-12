output "zone_id" {
  value       = aws_route53_zone.primary.zone_id
  description = "The Route 53 hosted zone ID"
}

output "name_servers" {
  value       = aws_route53_zone.primary.name_servers
  description = "The hosted zone name servers"
}
output "error_page_website_endpoint" {
  description = "S3 static website endpoint for error page"
  value       = aws_s3_bucket_website_configuration.error_page.website_endpoint
}
