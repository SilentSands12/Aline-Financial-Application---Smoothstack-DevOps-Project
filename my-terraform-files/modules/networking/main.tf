# modules/networking/main.tf
terraform {
  # Specify the required Terraform version
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0" # AWS provider version
    }
  }
}

# Create a VPC with the specified CIDR block
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr # CIDR block for the VPC

  enable_dns_support   = true # Enable DNS support for the VPC
  enable_dns_hostnames = true # Enable DNS hostnames for the VPC

  tags = {
    Name     = var.vpc_name # Tag for the VPC name
    Schedule = var.schedule # Schedule tag for organizational purposes
  }
}

# Create public subnets within the VPC
resource "aws_subnet" "public" {
  count             = length(var.public_subnets) # Number of public subnets to create
  vpc_id            = aws_vpc.this.id # ID of the VPC
  cidr_block        = var.public_subnets[count.index].cidr # CIDR block for the subnet
  availability_zone = var.public_subnets[count.index].availability_zone # Availability zone for the subnet

  map_public_ip_on_launch = true # Enable auto-assignment of public IP addresses

  tags = {
    Name     = var.public_subnets[count.index].name # Tag for the subnet name
    Schedule = var.schedule # Schedule tag for organizational purposes
    "kubernetes.io/role/elb" = "1" # Tag needed to connect with ingress
    "kubernetes.io/cluster/terraform-eks-cluster-jc" = "shared"
  }
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id # ID of the VPC to attach the gateway

  tags = {
    Name     = var.igw_name # Tag for the internet gateway name
    Schedule = var.schedule # Schedule tag for organizational purposes
  }
}

# Create a route table for the public subnets and associate it with the internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id # ID of the VPC to associate the route table

  route {
    cidr_block = "0.0.0.0/0" # CIDR block for the route (all traffic)
    gateway_id = aws_internet_gateway.this.id # ID of the internet gateway
  }

  tags = {
    Name     = var.route_table_name # Tag for the route table name
    Schedule = var.schedule # Schedule tag for organizational purposes
  }
}

# Associate the public subnets with the route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets) # Number of associations (one per subnet)
  subnet_id      = aws_subnet.public[count.index].id # ID of the subnet to associate
  route_table_id = aws_route_table.public.id # ID of the route table to associate with
}
