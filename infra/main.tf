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
  source                          = "./modules/eks"
  project                         = var.project
  environment                     = var.environment
  cluster_name                    = "cloudmart"
  vpc_id                          = module.vpc.vpc_id
  private_app_subnet_ids          = module.vpc.private_app_subnet_ids
  use_fargate                     = var.use_fargate
  kubernetes_version              = var.kubernetes_version
  node_instance_type              = var.node_instance_type
  desired_node_count              = var.desired_node_count
  team                            = var.team
  kms_key_id                      = module.kms.key_arn
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
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
