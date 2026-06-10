output "rto_service_minutes" {
  description = "RTO for service-level failures (minutes)"
  value       = var.rto_service_minutes
}

output "rto_region_hours" {
  description = "RTO for region-level outages (hours)"
  value       = var.rto_region_hours
}

output "rpo_db_minutes" {
  description = "RPO for live DB data (minutes)"
  value       = var.rpo_db_minutes
}

output "rpo_backup_hours" {
  description = "RPO for backup based recovery (hours)"
  value       = var.rpo_backup_hours
}
