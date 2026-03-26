variable "eks-cluster-id" {
  description = "The id of the eks-cluster get it via module.eks-cluster.id"
  type        = string
}

variable "OIDC-issuer-URL-eks" {
  description = "OIDC-issuer for the eks cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC get it via module.networking.vpc_id"
  type        = string
}

variable "eks-arn" {
  description = "EKS arn info"
  type        = string
}

variable "update_kubeconfig_trigger" {
  description = "Trigger for updating kubeconfig after EKS cluster creation"
  type        = string
}

variable "wait-for-cluster" {
  description = "Trigger for checking that EKS creation is complete"
  type        = string
}
