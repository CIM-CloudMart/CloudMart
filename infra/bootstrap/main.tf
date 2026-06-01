# ==================== CloudMart Infrastructure Bootstrap ====================
# This configuration runs with a local state backend.
# It provisions the resources required to support the remote S3 backend for the main configuration.

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

variable "project" {
  description = "Project name"
  type        = string
  default     = "cloudmart"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "team" {
  description = "Team name (used for globally unique S3 bucket naming)"
  type        = string
  default     = "team-axel"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

# ---------------------------------------------------------------------------
# Terraform & Provider Settings
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      Team        = var.team
      ManagedBy   = "Terraform-Bootstrap"
    }
  }
}

# ---------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------

# S3 Bucket for Terraform Remote State
resource "aws_s3_bucket" "tfstate" {
  bucket        = "${var.project}-tfstate-${var.team}"
  force_destroy = var.environment != "prod" # Allow deletion in non-prod environments

  tags = {
    Name = "${var.project}-tfstate-${var.team}"
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for Terraform State Locking
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = "${var.project}-tfstate-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.project}-tfstate-lock"
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "tfstate_bucket_name" {
  value       = aws_s3_bucket.tfstate.id
  description = "The name of the S3 bucket to store Terraform state files"
}

output "tfstate_bucket_arn" {
  value       = aws_s3_bucket.tfstate.arn
  description = "The ARN of the S3 bucket to store Terraform state files"
}

output "tfstate_lock_table_name" {
  value       = aws_dynamodb_table.tfstate_lock.name
  description = "The name of the DynamoDB table for state locking"
}
