/*
1. Initialize Terraform Configuration: Specify the required Terraform version and AWS/Kubernetes providers to ensure
   compatibility with the necessary features.
2. Configure Kubernetes Provider: Set up the Kubernetes provider by specifying the path to the kubeconfig file for cluster interaction.
3. Enable CloudWatch Observability Addon: Use the aws_eks_addon resource to enable the CloudWatch Observability addon in
   the EKS cluster for enhanced monitoring.
4. Define IAM Roles and Policies: Create an IAM policy document and role that allows the CloudWatch agent to assume roles via
   Web Identity Federation (IRSA) and attach the necessary CloudWatch Agent Server Policy to this role.
5. Create CloudWatch Dashboard: Define a CloudWatch dashboard with various widgets to monitor EKS cluster metrics, RDS metrics,
   and ELB request counts.
6. Deploy the CloudWatch Agent (Not shown): Although not included in the code snippet, typically, the CloudWatch agent is
   deployed as a DaemonSet using the configurations provided, ensuring the agent runs on every node.
*/

terraform {
  # Define the main Terraform configuration settings for the module.
  # Specify the required Terraform version and provider constraints.
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0" # Ensure compatibility with AWS provider features.
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"  # Ensure compatibility with Kubernetes provider features.
    }
  }
}

provider "kubernetes" {
  # Configure the Kubernetes provider with the kubeconfig file path.
  # This allows Terraform to interact with the Kubernetes cluster.
  config_path = "C:/Users/Canal/.kube/config"  # Full path to the kubeconfig file on the local system.
}

resource "aws_eks_addon" "cloudwatch_observability" {
  # Enable the CloudWatch Observability addon for the EKS cluster.
  # This addon integrates with CloudWatch to provide observability features like Container Insights.
  cluster_name             = var.eks-cluster-id  # Name of the EKS cluster.
  addon_name               = "amazon-cloudwatch-observability"  # Addon to enable CloudWatch observability.
  service_account_role_arn = aws_iam_role.cloudwatch_agent_irsa.arn  # IAM role used by the addon to interact with AWS services.
}

resource "aws_iam_role" "cloudwatch_agent_irsa" {
  # Create an IAM role that can be assumed by the CloudWatch agent using IRSA.
  name               = "CloudWatchAgentIRSA-JC"  # Name of the IAM role.
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_agent_assume_role_policy.json  # Use the assume role policy defined earlier.
}

data "aws_iam_policy_document" "cloudwatch_agent_assume_role_policy" {
  # Define an IAM policy document that allows the CloudWatch agent to assume the role using Web Identity Federation (IRSA).
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]  # Allow the action to assume roles via Web Identity.

    principals {
      type        = "Federated"  # Type of principal, in this case, a federated identity.
      identifiers = [var.eks-arn]  # The ARN of the OIDC provider associated with the EKS cluster.
    }

    condition {
      test     = "StringEquals"
      variable = "${var.OIDC-issuer-URL-eks}:sub"  # The subject field in the OIDC token.
      values   = ["system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"]  # Specify the service account that can assume this role.
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_irsa_policy" {
  # Attach the CloudWatch Agent Server Policy to the IAM role.
  # This policy allows the role to perform necessary actions to collect metrics and logs.
  role       = aws_iam_role.cloudwatch_agent_irsa.name  # The IAM role to attach the policy to.
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"  # ARN of the policy to attach.
}

# Create CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "eks_cluster_dashboard_jc" {
  # Define a CloudWatch dashboard to monitor EKS cluster metrics and other AWS resources.
  dashboard_name = "EKSClusterDashboard-JC"  # Name of the CloudWatch dashboard.

  dashboard_body = jsonencode({
    widgets = [
      # Widget to monitor incoming log events and incoming bytes in the specified log group.
      {
        type = "metric",
        x = 12,
        y = 12,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/Logs", "IncomingLogEvents", "LogGroupName", "/aws/eks/terraform-eks-cluster-jc/cluster" ],
            [ ".", "IncomingBytes", ".", "/aws/eks/terraform-eks-cluster-jc/cluster" ],
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "EKS Incoming Log Events",  # Title of the widget.
        }
      },
      # Widget to monitor CPU utilization and free storage space for the specified RDS instance.
      {
        type = "metric",
        x = 0,
        y = 6,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db-instance-identifier ],
            [ ".", "FreeStorageSpace", ".", var.db-instance-identifier ],
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "RDS Metrics",  # Title of the widget.
        }
      },
      # Widget to monitor node CPU and memory utilization for the EKS cluster.
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [ "ContainerInsights", "node_cpu_utilization", "ClusterName", "terraform-eks-cluster-jc" ],
            [ ".", "node_memory_utilization", ".", "terraform-eks-cluster-jc" ]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "us-east-1",
          "title": "Node CPU & Memory Utilization"  # Title of the widget.
        }
      },
      # Widget to monitor node disk space utilization for the EKS cluster.
      {
        "type": "metric",
        "x": 0,
        "y": 12,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [ "ContainerInsights", "node_filesystem_utilization", "ClusterName", "terraform-eks-cluster-jc" ]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "us-east-1",
          "title": "Node Disk Space Utilization"  # Title of the widget.
        }
      },
      # Widget to monitor the number of database connections for the specified RDS instance.
      {
        "type": "metric",
        "x": 12,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.db-instance-identifier ]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "us-east-1",
          "title": "Database Connections"  # Title of the widget.
        }
      },
      # Widget to monitor read and write latency for the specified RDS instance.
      {
        "type": "metric",
        "x": 12,
        "y": 6,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/RDS", "ReadLatency", "DBInstanceIdentifier", var.db-instance-identifier ],
            [ ".", "WriteLatency", ".", var.db-instance-identifier ]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "us-east-1",
          "title": "Read/Write Latency"  # Title of the widget.
        }
      },
      # Widget to monitor the number of requests received by a specific ELB (Elastic Load Balancer).
      {
        "type": "metric",
        "x": 0,
        "y": 24,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "<load_balancer_name>" ]
          ],
          "view": "timeSeries",
          "stacked": false,
          "region": "us-east-1",
          "title": "ELB Request Count"  # Title of the widget.
        }
      },
    ]
  })
}
