variable "release_name" {
  description = "The name of the Helm release"
  type        = string
  default     = "nginx-ingress-controller-tc"
}

variable "repository" {
  description = "The Helm chart repository URL"
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
}

variable "chart" {
  description = "The name of the Helm chart"
  type        = string
  default     = "nginx-ingress-controller"
}

variable "service_type_key" {
  description = "The name of the key to set for the service type"
  type        = string
  default     = "service.type"
}

variable "service_type_value" {
  description = "The value to set for the service type"
  type        = string
  default     = "LoadBalancer"
}
