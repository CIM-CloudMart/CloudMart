variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue for depth metrics"
  type        = string
}

variable "subscriber_emails" {
  description = "Subscriber emails for application metric alarms"
  type        = list(string)
}

