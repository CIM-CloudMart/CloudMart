output "bucket_name" {
  value       = aws_s3_bucket.storage.id
  description = "The name of the storage S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.storage.arn
  description = "The ARN of the storage S3 bucket"
}

output "failover_website_domain" {
  value       = aws_s3_bucket_website_configuration.failover_website.website_domain
  description = "The failover website domain name"
}

output "failover_website_endpoint" {
  value       = aws_s3_bucket_website_configuration.failover_website.website_endpoint
  description = "The failover website endpoint"
}
