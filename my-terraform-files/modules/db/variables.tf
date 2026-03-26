variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs"
  type        = list(string)
}

variable "eks_cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  type        = string
}

variable "schedule" {
  description = "Tag to define schedule"
  type        = string
  default     = "office-hours"
}

variable "eks_node_security_group_id" {
  description = "The security group ID of the EKS node security group"
  type        = string
}