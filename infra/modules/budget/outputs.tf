output "budget_id" {
  value       = aws_budgets_budget.monthly_budget.id
  description = "The ID of the AWS Budget"
}
