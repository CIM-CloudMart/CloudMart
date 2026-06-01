output "zone_id" {
  value       = aws_route53_zone.primary.zone_id
  description = "The Route 53 hosted zone ID"
}

output "name_servers" {
  value       = aws_route53_zone.primary.name_servers
  description = "The hosted zone name servers"
}
