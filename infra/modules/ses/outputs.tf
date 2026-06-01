output "ses_email_identity_arn" {
  value       = aws_ses_email_identity.notification_email.arn
  description = "The ARN of the verified SES email identity"
}
