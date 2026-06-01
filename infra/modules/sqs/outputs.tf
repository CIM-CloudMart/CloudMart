output "queue_name" {
  value       = aws_sqs_queue.order_events.name
  description = "The name of the SQS queue"
}

output "queue_arn" {
  value       = aws_sqs_queue.order_events.arn
  description = "The ARN of the SQS queue"
}

output "queue_url" {
  value       = aws_sqs_queue.order_events.url
  description = "The URL of the SQS queue"
}
