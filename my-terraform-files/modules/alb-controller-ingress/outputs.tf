# Output the IAM role ARN
output "alb_ingress_controller_role_arn" {
  description = "IAM role ARN for the ALB Ingress Controller"
  value       = aws_iam_role.lb_controller_role.arn
}

# Output the IAM role name
output "alb_ingress_controller_role_name" {
  description = "IAM role name for the ALB Ingress Controller"
  value       = aws_iam_role.lb_controller_role.name
}

