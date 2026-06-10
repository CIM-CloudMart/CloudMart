# Core infrastructure modules

module "vpc" {
  source      = "./modules/vpc"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  region      = var.region
  team        = var.team
  cluster_name = "cloudmart"
  single_nat_gateway = var.single_nat_gateway
}

module "kms" {
  source      = "./modules/kms"
  project     = var.project
  environment = var.environment
}

module "ses" {
  source      = "./modules/ses"
  project     = var.project
  environment = var.environment
  from_email  = var.from_email
}

module "eks" {
  source       = "./modules/eks-data"
  cluster_name = "cloudmart"
}

module "waf" {
  source      = "./modules/waf"
  project     = var.project
  environment = var.environment
  enable_waf  = var.enable_waf
}

module "route53" {
  source      = "./modules/route53"
  project     = var.project
  environment = var.environment
  domain_name = var.domain_name
}

module "budget" {
  source            = "./modules/budget"
  project           = var.project
  environment       = var.environment
  limit_amount      = var.limit_amount
  subscriber_emails = var.subscriber_emails
}

module "security" {
  source              = "./modules/security"
  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  enable_guardduty    = var.enable_guardduty
  enable_security_hub = false
}

module "disaster_recovery" {
  source = "./modules/disaster-recovery"
}

# Velero Backup - S3 bucket + IAM Role for Kubernetes manifest & volume backups

locals {
  # Strip "https://" from the OIDC URL — required for IAM trust policy conditions
  oidc_provider_url_stripped = replace(module.eks.oidc_provider_url, "https://", "")
}

module "velero_backup" {
  source                    = "./modules/velero-backup"
  project                   = var.project
  environment               = var.environment
  team                      = var.team
  kms_key_arn               = module.kms.key_arn
  oidc_provider_arn         = module.eks.oidc_provider_arn
  oidc_provider_url_stripped = local.oidc_provider_url_stripped
}
