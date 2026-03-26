/*
1. The IAM policy is loaded and created to define permissions required by the Load Balancer Controller.
2. The EKS cluster's OIDC provider is set up to enable secure authentication.
3. An IAM role is created and attached to the policy, allowing the Load Balancer Controller to use these permissions.
4. The ALB Ingress Controller is deployed to the EKS cluster using Helm, configuring it to use the created IAM role and other necessary parameters.
5. Ingress rules are defined to manage and route traffic for different services within the cluster.
6. An additional Ingress resource is created to handle traffic redirections.
7. A Service Account is created and linked with the IAM role, ensuring the Load Balancer Controller has the required access.
 */

terraform {
  # Main Terraform configuration for the alb-controller-ingress module
  # Specify the required Terraform version
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0" # AWS provider version
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"  # Example version constraint for the local provider
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"  # Example version constraint for tls provider
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"  # Example version constraint for helm provider
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"  # Specify a version constraint for the Kubernetes provider
    }
  }
}
provider "helm" {
  kubernetes {
    config_path = "C:/Users/Canal/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "C:/Users/Canal/.kube/config"  # Use the full path to the kubeconfig file
}

# Load the IAM policy JSON from a file
data "local_file" "lb_controller_policy" {
  filename = "${path.module}/../../Resources/load-balancer-controller-iam-role-policy.json"
}

# Create an IAM policy for the Load Balancer Controller
resource "aws_iam_policy" "lb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy-jc"  # Name of the IAM policy
  description = "IAM policy for AWS Load Balancer Controller"  # Description of the policy
  policy      = data.local_file.lb_controller_policy.content  # Policy document from the JSON file
}

# Create an IAM role for the ALB Ingress Controller with trust policy
resource "aws_iam_role" "lb_controller_role" {
  name               = "AmazonEKSLoadBalancerControllerRole-jc"  # Name of the IAM role
  assume_role_policy = jsonencode({  # Trust policy allowing the OIDC provider to assume this role
    Version = "2012-10-17"  # Policy version
    Statement = [
      {
        Effect = "Allow"  # Allow action
        Principal = {
          Federated = var.eks-arn  # OIDC provider ARN
        }
        Action = "sts:AssumeRoleWithWebIdentity"  # Action allowed
        Condition = {
          StringEquals = {
            "${replace(var.OIDC-issuer-URL-eks, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller-jc"  # Condition for the OIDC token
            "${replace(var.OIDC-issuer-URL-eks, "https://", "")}:aud" = "sts.amazonaws.com"  # Audience condition for the OIDC token
          }
        }
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "alb_ingress_controller_policy" {
  role       = aws_iam_role.lb_controller_role.name  # Role to attach the policy to
  policy_arn = aws_iam_policy.lb_controller_policy.arn  # ARN of the policy to attach
}

# Deploy the ALB Ingress Controller using Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"  # Name of the Helm release
  repository = "https://aws.github.io/eks-charts"  # Helm chart repository
  chart      = "aws-load-balancer-controller"  # Helm chart name
  namespace  = "kube-system"  # Kubernetes namespace for deployment

  # Set EKS cluster name
  set {
    name  = "clusterName"
    value = var.eks-cluster-id  # EKS cluster ID
  }

  # Set Service Account name
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller-jc"  # Service Account name
  }

  # Set AWS region
  set {
    name  = "region"
    value = "us-east-1"  # AWS region
  }

  # Set VPC ID
  set {
    name  = "vpcId"
    value = var.vpc_id  # VPC ID
  }

  # Do not create a new Service Account
  set {
    name  = "serviceAccount.create"
    value = "false"  # Indicates to use an existing Service Account
  }

  # Attach IAM role to the Service Account
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller_role.arn  # ARN of the IAM role
  }

  # Ensure that the IAM role policy attachment is completed first
  depends_on = [
    aws_iam_role_policy_attachment.alb_ingress_controller_policy,  # Ensure IAM role policy attachment
    kubernetes_service_account.alb_controller,  # Ensure Service Account is created
    var.wait-for-cluster, # Ensure EKS is created and ready to go
    var.update_kubeconfig_trigger  # Ensure kubeconfig is updated
  ]

}

# Create a Kubernetes Service Account for the ALB Controller with IAM role annotation
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller-jc"  # Name of the Service Account
    namespace = "kube-system"  # Kubernetes namespace where the Service Account will be created
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller_role.arn  # IAM role ARN to be used by the Service Account
    }
    labels = {
      "app.kubernetes.io/component" = "controller"  # Label indicating this is a controller component
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"  # Label for the controller name
    }
  }

  depends_on = [
    aws_iam_role.lb_controller_role,  # Ensure IAM role is created first
    var.wait-for-cluster, # Ensure EKS is created and ready to go
    var.update_kubeconfig_trigger # Dependency on kubeconfig_trigger output from eks
    ]

}

