variable "services" {
	description = "List of services to create log groups for"
	type        = list(string)
	default     = ["frontend","product-service","order-service","user-service","notification-service"]
}

resource "aws_cloudwatch_log_group" "service_logs" {
	for_each = toset(var.services)
	name     = "/cloudmart/${each.key}-${var.environment}"
	retention_in_days = var.environment == "prod" ? 90 : 30

	tags = {
		Project     = var.project
		Environment = var.environment
	}
}

resource "aws_cloudwatch_dashboard" "main" {
	dashboard_name = "${var.project}-dashboard-${var.environment}"
	dashboard_body = jsonencode({
		widgets = [
			{
				type = "text"
				x = 0
				y = 0
				width = 24
				height = 2
				properties = {
					markdown = "# ${var.project} - ${var.environment}"
				}
			}
		]
	})

	depends_on = [aws_cloudwatch_log_group.service_logs]
}

# Alarms and more detailed dashboards should be added per service integration
