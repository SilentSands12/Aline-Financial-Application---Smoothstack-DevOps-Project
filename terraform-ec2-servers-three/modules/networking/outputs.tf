# modules/networking/outputs.tf
output "subnet_id" {
  description = "The ID of the subnet"
  value       = data.aws_subnet.default.id
}
output "elastic-security-group" {
  description = "The security group for the elastic and instances"
  value       = aws_security_group.ansible_security_jc.id
}