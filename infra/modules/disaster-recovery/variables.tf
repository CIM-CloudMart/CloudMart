# variables.tf – Disaster Recovery target definitions

variable "rto_service_minutes" {
  description = "Target Recovery Time Objective for service‑level failures (minutes)."
  type        = number
  default     = 10  # 5‑15 min range as defined in docs
}

variable "rto_region_hours" {
  description = "Target Recovery Time Objective for an entire AWS region outage (hours)."
  type        = number
  default     = 3   # 2‑4 h range as defined in docs
}

variable "rpo_db_minutes" {
  description = "Target Recovery Point Objective for live relational data (minutes). Zero means near‑zero data loss via Multi‑AZ sync."
  type        = number
  default     = 0
}

variable "rpo_backup_hours" {
  description = "Maximum allowable data age for backup‑based recovery (hours)."
  type        = number
  default     = 168  # 7‑day retention
}

# Optional: expose as locals for easy reference in other modules
locals {
  rto_service   = var.rto_service_minutes
  rto_region    = var.rto_region_hours
  rpo_db        = var.rpo_db_minutes
  rpo_backup    = var.rpo_backup_hours
}
