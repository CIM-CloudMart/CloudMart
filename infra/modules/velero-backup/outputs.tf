output "bucket_name" {
  description = "Velero S3 backup bucket name"
  value       = aws_s3_bucket.velero.bucket
}

output "bucket_arn" {
  description = "Velero S3 backup bucket ARN"
  value       = aws_s3_bucket.velero.arn
}

output "velero_role_arn" {
  description = "IAM Role ARN for Velero service account (use in Helm values)"
  value       = aws_iam_role.velero.arn
}
