# modules/networking/variables.tf

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "schedule" {
  description = "Schedule tag"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets"
  type = list(object({
    cidr             = string
    availability_zone = string
    name             = string
  }))
}

variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
}

variable "route_table_name" {
  description = "Name of the Route Table"
  type        = string
}
