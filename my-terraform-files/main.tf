# Terraform attribute to specify version
# This ensures compatibility and prevents potential issues when using different Terraform versions.
terraform {
  # Configuration for storing the Terraform state file in an S3 bucket
  backend "s3" {
    bucket         = "terraform-s3-bucket-jc" # S3 bucket to store the state file
    key            = "aline-infrastructure-terraform-files/terraform.tfstate" # Path to the state file within the bucket
    region         = "us-east-1" # AWS region where the bucket is located
    dynamodb_table = "terraform-state-lock-jc" # DynamoDB table for state locking and consistency checks
    encrypt        = true # Encrypt the state file for security
  }

  # Specify the required providers and their versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0" # AWS provider version
    }
  }

  # Specify the required Terraform version
  required_version = ">= 1.3.2"
}

# Provider configuration for AWS
provider "aws" {
  region = "us-east-1" # AWS region to deploy resources in
}

# Module for networking
module "networking" {
  source          = "./modules/networking" # Path to the networking module
  vpc_cidr        = "10.0.0.0/16" # CIDR block for the VPC
  vpc_name        = "terraform-vpc-jc" # Name of the VPC
  schedule        = "office-hours" # Tag for scheduling
  igw_name        = "terraform-gateway-jc" # Name of the internet gateway
  route_table_name = "public-route-table-jc" # Name of the route table

  # Configuration for public subnets
  public_subnets = [
    {
      cidr             = "10.0.10.0/24" # CIDR block for the subnet
      availability_zone = "us-east-1a" # Availability zone for the subnet
      name             = "public-a-jc" # Name of the subnet
    },
    {
      cidr             = "10.0.20.0/24"
      availability_zone = "us-east-1b"
      name             = "public-b-jc"
    },
    {
      cidr             = "10.0.30.0/24"
      availability_zone = "us-east-1c"
      name             = "public-c-jc"
    }
  ]
}

# Module for EKS cluster role
module "eks-cluster-role" {
  source = "./modules/eks-cluster-role" # Path to the EKS cluster role module
  eks-role-name = "terraform-eks-cluster-role-jc" # Name of the EKS cluster role
  eks-sg-name = "terraform-eks-cluster-sg-jc" # Name of the EKS security group
  schedule = "office-hours" # Tag for scheduling
  vpc_id = module.networking.vpc_id # VPC ID from the networking module
}

# Module for EKS worker node role
module "eks-worker-node-role" {
  source = "./modules/eks-worker-node-role" # Path to the EKS worker node role module
  schedule = "office-hours" # Tag for scheduling
  worker-node-role-name = "terraform-eks-worker-node-role-jc" # Name of the worker node role
  worker-node-sg-name = "terraform-eks-worker-node-sg-jc" # Name of the worker node security group
  vpc_id = module.networking.vpc_id # VPC ID from the networking module
}

# Module for database configuration
module "db" {
  source = "./modules/db" # Path to the database module

  vpc_id                       = module.networking.vpc_id # VPC ID from the networking module
  subnet_ids                   = module.networking.public_subnet_ids # Subnet IDs from the networking module
  eks_cluster_security_group_id = module.eks-cluster-role.eks_security_group_id # Security group ID from the EKS cluster role module
  eks_node_security_group_id = module.eks.node_security_group_id # Security group ID from the EKS cluster role module
  schedule                     = "office-hours" # Tag for scheduling
}

# Module for database configuration
module "alb-controller-ingress" {
  source = "./modules/alb-controller-ingress" # Path to the alb-controller module

  vpc_id                       = module.networking.vpc_id # VPC ID from the networking module
  eks-cluster-id               = module.eks.cluster_name # Id of the eks cluster from the module (my name is same as id)
  OIDC-issuer-URL-eks          = module.eks.cluster_oidc_issuer_url # OIDC issuer URL from EKS cluster
  eks-arn                      = module.eks.oidc_provider_arn # arn from EKS cluster
  update_kubeconfig_trigger    = null_resource.update_kubeconfig.id
  wait-for-cluster             = null_resource.wait_for_cluster.id
}

# module "cloudwatch" {
#   source = "./modules/cloudwatch"
#
#   OIDC-issuer-URL-eks          = module.eks.oidc_provider # OIDC issuer URL from EKS cluster
#   eks-arn                      = module.eks.oidc_provider_arn # arn from EKS cluster
#   eks-cluster-id               = module.eks.cluster_name # Id of the eks cluster from the module (my name is same as id)
#   vpc_id                       = module.networking.vpc_id # VPC ID from the networking module
#   update_kubeconfig_trigger    = null_resource.update_kubeconfig.id
#   wait-for-cluster             = null_resource.wait_for_cluster.id
#   eks-node-policies-ids        = [module.eks-worker-node-role.eks_worker_worker-node_policy_id, module.eks-worker-node-role.eks_worker_instance-core_policy_id]
#   db-instance-identifier       = module.db.db_instance_identifier
# }

# Module for EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws" # Source of the EKS module
  version = "~> 20.0" # Version of the EKS module

  cluster_name    = "terraform-eks-cluster-jc" # Name of the EKS cluster
  cluster_version = "1.29" # Version of the EKS cluster

  cluster_endpoint_public_access = true # Public access to the EKS cluster endpoint
  create_cloudwatch_log_group = false # Disable creation of CloudWatch log group
  kms_key_enable_default_policy = false # Disable default KMS key policy

  # Configuration for EKS cluster add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.networking.vpc_id # VPC ID from the networking module
  subnet_ids               = module.networking.public_subnet_ids # Subnet IDs from the networking module
  control_plane_subnet_ids = module.networking.public_subnet_ids # Control plane subnet IDs

  cluster_security_group_id = module.eks-cluster-role.eks_security_group_id # Security group ID from the EKS cluster role module

  iam_role_name             = module.eks-cluster-role.role_name # IAM role name from the EKS cluster role module
  enable_irsa               = true # Enable IAM Roles for Service Accounts (IRSA)

  # Default configuration for EKS managed node groups
  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"] # Instance type for the managed node group
  }

  # Configuration for EKS managed node groups
  eks_managed_node_groups = {
    terra-nodegroup = {
      node_group_name = "terraform-node-group-jc" # Name of the node group
      min_size        = 2 # Minimum size of the node group
      max_size        = 2 # Maximum size of the node group
      desired_size    = 2 # Desired size of the node group
      instance_types  = ["t2.small"] # Instance type for the node group
      capacity_type   = "ON_DEMAND" # Capacity type for the node group
      security_group_ids = module.eks-worker-node-role.eks_worker_node_security_group_id # Security group ID from the EKS worker node role module
      iam_role_name      = module.eks-worker-node-role.role_name # IAM role name from the EKS worker node role module
      subnet_ids         = module.networking.public_subnet_ids # Subnet IDs from the networking module

      # Additional tags for the node group
      additional_node_group_tags = {
        "terraform-node-group"                  = "NodeGroup"
        "schedule"                              = "office-hours"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true # Grant admin permissions to the cluster creator
  cluster_encryption_config = {} # Cluster encryption configuration

  # Tags for the EKS cluster
  tags = {
    Terraform   = "true"
    Schedule    = "office-hours"
  }
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-1 --name terraform-eks-cluster-jc"
  }

  depends_on = [module.eks, module.eks-cluster-role, module.networking, module.eks-worker-node-role]
}

resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "kubectl get nodes --request-timeout=10s"
    environment = {
      KUBECONFIG = "C:/Users/Canal/.kube/config"
    }
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [module.eks, module.eks-cluster-role, module.networking, module.eks-worker-node-role,
      null_resource.update_kubeconfig] # Wait for update kubeconfig context to be put

}




