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

# Create an IAM role for the EKS cluster
resource "aws_iam_role" "terraform-eks-cluster-role-jc" {
  name = var.eks-role-name # Name of the IAM role from a variable

  # Policy that allows EKS to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17" # Policy version
    Statement = [
      {
        Action = "sts:AssumeRole" # Allow the sts:AssumeRole action
        Effect = "Allow" # Allow the action
        Principal = {
          Service = "eks.amazonaws.com" # Specify the EKS service as the principal
        }
      }
    ]
  })

  tags = {
    Name = var.eks-role-name # Tag for the role name
    Schedule = var.schedule # Schedule tag for organizational purposes
  }
}

# Attach the AmazonEKSClusterPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" # ARN of the policy
  role       = aws_iam_role.terraform-eks-cluster-role-jc.name # IAM role name
}

# Attach the AmazonEKSVPCResourceController policy to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController" # ARN of the policy
  role       = aws_iam_role.terraform-eks-cluster-role-jc.name # IAM role name
}

# Attach the AmazonEKSServicePolicy to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy" # ARN of the policy
  role       = aws_iam_role.terraform-eks-cluster-role-jc.name # IAM role name
}

# Security group for the EKS cluster control plane
resource "aws_security_group" "terraform-eks-cluster-sg-jc" {
  vpc_id = var.vpc_id # VPC ID where the security group will be created

  # Ingress rule to allow HTTPS traffic to the EKS control plane
  ingress {
    from_port   = 443 # Starting port (HTTPS)
    to_port     = 443 # Ending port (HTTPS)
    protocol    = "tcp" # Protocol
    cidr_blocks = ["0.0.0.0/0"] # Allow from any IP address
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0 # Starting port (all ports)
    to_port     = 0 # Ending port (all ports)
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow to any IP address
  }

  tags = {
    Name = var.eks-sg-name # Tag for the security group name
    Schedule = var.schedule # Schedule tag for organizational purposes
  }
}
