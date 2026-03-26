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

# Create an IAM role for the EKS worker nodes
resource "aws_iam_role" "terraform-eks-worker-node-role-jc" {
  name = var.worker-node-role-name # Name of the IAM role from a variable

  # Policy that allows EC2 instances to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17" # Policy version
    Statement = [
      {
        Action = "sts:AssumeRole" # Allow the sts:AssumeRole action
        Effect = "Allow" # Allow the action
        Principal = {
          Service = "ec2.amazonaws.com" # Specify the EC2 service as the principal
        }
      }
    ]
  })

  tags = {
    Name = var.worker-node-role-name # Tag for the role name
    Schedule = var.schedule # Schedule tag for organizational purposes
  }
}

# Attach the AmazonEKSWorkerNodePolicy to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" # ARN of the policy
  role       = aws_iam_role.terraform-eks-worker-node-role-jc.name # IAM role name
}

# Attach the AmazonRDSDataFullAccess policy to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonRDSDataFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess" # ARN of the policy
  role       = aws_iam_role.terraform-eks-worker-node-role-jc.name # IAM role name
}

# Attach the AmazonEC2ContainerRegistryReadOnly policy to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # ARN of the policy
  role       = aws_iam_role.terraform-eks-worker-node-role-jc.name # IAM role name
}

# Attach the AmazonEKS_CNI_Policy to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" # ARN of the policy
  role       = aws_iam_role.terraform-eks-worker-node-role-jc.name # IAM role name
}

# Attach the AmazonSSMManagedInstanceCore policy to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # ARN of the policy
  role       = aws_iam_role.terraform-eks-worker-node-role-jc.name # IAM role name
}

# # Attach CloudWatch agent policies to the IAM role
# resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
#   role       = aws_iam_role.terraform-eks-worker-node-role-jc.name
#   policy_arn  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }

# Create a security group for EKS worker nodes without referencing RDS security group
resource "aws_security_group" "terraform-eks-worker-node-sg-jc" {
  vpc_id = var.vpc_id # VPC ID where the security group will be created

  # Ingress rule to allow all traffic to the worker nodes
  ingress {
    from_port   = 0 # Starting port (all ports)
    to_port     = 0 # Ending port (all ports)
    protocol    = "-1" # All protocols
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
    Name     = var.worker-node-sg-name # Tag for the security group name
    Schedule = var.schedule # Schedule tag for organizational purposes
  }
}
