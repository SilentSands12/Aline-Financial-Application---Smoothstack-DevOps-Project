output "role_name" {
  value = aws_iam_role.terraform-eks-cluster-role-jc.name
}

output "role_arn" {
  value = aws_iam_role.terraform-eks-cluster-role-jc.arn
}

output "eks_security_group_name" {
  value = aws_security_group.terraform-eks-cluster-sg-jc.name
}

output "eks_security_group_id" {
  value = aws_security_group.terraform-eks-cluster-sg-jc.id
}