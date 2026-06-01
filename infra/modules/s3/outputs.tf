output "bucket_name" {
  value       = aws_s3_bucket.storage.id
  description = "The name of the storage S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.storage.arn
  description = "The ARN of the storage S3 bucket"
}
