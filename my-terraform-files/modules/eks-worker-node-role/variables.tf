variable "worker-node-role-name" {
  description = "The name of the EKS worker node role"
  type        = string
}

variable "worker-node-sg-name" {
  description = "The name of the security group for the EKS worker node role"
  type        = string
}

variable "schedule" {
  description = "The name of the scheduler tag"
  type        = string
}

variable "vpc_id" {
  description = "The vpc id that will be used for this worker node"
  type        = string
}