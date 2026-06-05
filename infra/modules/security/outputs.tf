output "guardduty_detector_id" {
  description = "GuardDuty detector ID (null when disabled)"
  value       = try(aws_guardduty_detector.main[0].id, null)
}
