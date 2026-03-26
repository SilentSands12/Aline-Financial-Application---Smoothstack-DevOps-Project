output "role_name" {
  value = aws_iam_role.terraform-eks-worker-node-role-jc.name
}

output "role_arn" {
  value = aws_iam_role.terraform-eks-worker-node-role-jc.arn
}

output "eks_worker_node_security_group_name" {
  value = aws_security_group.terraform-eks-worker-node-sg-jc.name
}

output "eks_worker_node_security_group_id" {
  value = aws_security_group.terraform-eks-worker-node-sg-jc.id
}

output "eks_worker_worker-node_policy_id" {
  value = aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy.id
}

output "eks_worker_instance-core_policy_id" {
  value = aws_iam_role_policy_attachment.AmazonSSMManagedInstanceCore.id
}