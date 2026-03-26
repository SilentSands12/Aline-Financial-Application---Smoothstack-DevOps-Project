output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.default.id
}

output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.default.endpoint
}

output "db_instance_identifier" {
  description = "The db identifier"
  value       = aws_db_instance.default.identifier
}