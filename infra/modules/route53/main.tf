# ==================== Route 53 Module ====================

resource "aws_route53_zone" "primary" {
  name          = var.domain_name
  force_destroy = var.environment != "prod"

  tags = {
    Name        = "${var.project}-zone-${var.environment}"
    Environment = var.environment
  }
}

# Health check pointing to the Application Load Balancer
resource "aws_route53_health_check" "alb" {
  count             = var.alb_dns_name != null && var.alb_dns_name != "" ? 1 : 0
  fqdn              = var.alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name        = "${var.project}-alb-hc-${var.environment}"
    Environment = var.environment
  }
}

# Primary DNS CNAME Record pointing to ALB
resource "aws_route53_record" "primary" {
  count           = var.alb_dns_name != null && var.alb_dns_name != "" ? 1 : 0
  zone_id         = aws_route53_zone.primary.zone_id
  name            = "app.${var.domain_name}"
  type            = "CNAME"
  ttl             = "60"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "primary"
  records         = [var.alb_dns_name]
  health_check_id = aws_route53_health_check.alb[0].id
}

# Secondary DNS CNAME Record pointing to S3 Website (Error Page)
resource "aws_route53_record" "secondary" {
  count           = var.alb_dns_name != null && var.alb_dns_name != "" && var.failover_s3_website_domain != null ? 1 : 0
  zone_id         = aws_route53_zone.primary.zone_id
  name            = "app.${var.domain_name}"
  type            = "CNAME"
  ttl             = "60"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "secondary"
  records        = [var.failover_s3_website_domain]
}
