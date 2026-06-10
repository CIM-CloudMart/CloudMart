module "core" {
  source = "../../"

  project            = var.project
  environment        = var.environment
  team               = var.team
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  single_nat_gateway = var.single_nat_gateway
  from_email         = var.from_email
  use_fargate        = var.use_fargate
  kubernetes_version = var.kubernetes_version
  node_instance_type = var.node_instance_type
  desired_node_count = var.desired_node_count
  enable_waf         = var.enable_waf
  domain_name        = var.domain_name
  limit_amount       = var.limit_amount
  subscriber_emails  = var.subscriber_emails
  enable_guardduty   = var.enable_guardduty
}
