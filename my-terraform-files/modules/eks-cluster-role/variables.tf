variable "eks-role-name" {
  description = "The name of the EKS cluster role"
  type        = string
}

variable "eks-sg-name" {
  description = "The name of the security group for the EKS cluster role"
  type        = string
}

variable "schedule" {
  description = "Schedule tag"
  type        = string
}

variable "vpc_id" {
  description = "The vpc id that will be used for the eks role"
  type        = string
}