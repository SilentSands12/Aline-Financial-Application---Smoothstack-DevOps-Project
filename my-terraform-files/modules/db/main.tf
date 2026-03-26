terraform { # Main Terraform configuration for the DB module
  # Specify the required Terraform version
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0" # AWS provider version
    }
  }

}

# Retrieve the secret information from AWS Secrets Manager
data "aws_secretsmanager_secret" "db_credentials_jc" {
  name = "db_credentials_jc" # Name of the secret in Secrets Manager
}

# Retrieve the latest version of the secret
data "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.db_credentials_jc.id # Reference the secret ID
}

# Decode the secret JSON string into a local variable
locals {
  db_credentials_jc = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)
}

# Create a security group for the RDS instance
resource "aws_security_group" "terraform-rds-security-group-jc" {
  vpc_id = var.vpc_id # VPC ID where the security group will be created

  tags = {
    Name     = "terraform-rds-security-group-jc" # Name tag for the security group
    Schedule = var.schedule # Schedule tag for organizational purposes
  }
}

# Allow all ingress traffic from the EKS cluster security group to the RDS security group
resource "aws_security_group_rule" "rds_ingress_all" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1" # All protocols
  security_group_id        = aws_security_group.terraform-rds-security-group-jc.id
  source_security_group_id = var.eks_cluster_security_group_id
}

# Allow MySQL traffic (port 3306) from the EKS cluster security group to the RDS security group
resource "aws_security_group_rule" "rds_ingress_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp" # TCP protocol
  security_group_id        = aws_security_group.terraform-rds-security-group-jc.id
  source_security_group_id = var.eks_cluster_security_group_id
}

# Allow MySQL/Aurora traffic from the EKS worker node security group
resource "aws_security_group_rule" "rds_ingress_mysql_from_eks_cluster_node" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.terraform-rds-security-group-jc.id
  source_security_group_id = var.eks_node_security_group_id
}

# Allow all egress traffic from the RDS security group
resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # All protocols
  security_group_id = aws_security_group.terraform-rds-security-group-jc.id
  cidr_blocks       = ["0.0.0.0/0"] # Allow to all IPs
}

# Create a subnet group for the RDS instance
resource "aws_db_subnet_group" "terraform-main-subnet-group-jc" {
  name       = "main-subnet-group-jc" # Name of the subnet group
  subnet_ids = var.subnet_ids # List of subnet IDs

  tags = {
    Name = "terraform-main-subnet-group-jc" # Name tag for the subnet group
    Schedule = var.schedule # Schedule tag for organizational purposes
  }
}

# Create a DB parameter group for MySQL
resource "aws_db_parameter_group" "my_mysql_parameter_group" {
  name   = "my-mysql-parameter-group" # Name of the parameter group
  family = "mysql8.0" # Database family for MySQL 8.0

  parameter {
    name  = "max_connections" # Parameter name
    value = "100" # Parameter value
  }
}

# Create the RDS instance
resource "aws_db_instance" "default" {
  allocated_storage      = 20 # Storage size in GB
  identifier             = "terraform-rds-jc" # Unique identifier for the RDS instance
  storage_type           = "gp2" # General Purpose SSD storage
  db_name                = "aline_financial_db" # Database name
  engine                 = "mysql" # Database engine
  engine_version         = "8.0.35" # Engine version
  instance_class         = "db.t3.micro" # Instance class
  username               = local.db_credentials_jc.username # Username from the secret
  password               = local.db_credentials_jc.password # Password from the secret
  parameter_group_name   = aws_db_parameter_group.my_mysql_parameter_group.name # DB parameter group
  skip_final_snapshot    = true # Skip final snapshot when deleting the instance
  publicly_accessible    = true # Make the instance publicly accessible
  db_subnet_group_name   = aws_db_subnet_group.terraform-main-subnet-group-jc.name # DB subnet group
  vpc_security_group_ids = [aws_security_group.terraform-rds-security-group-jc.id] # Security group for the RDS instance
}

# resource "aws_cloudwatch_metric_alarm" "rds_cpu_credit_balance_alarm" {
#   alarm_name                = "rds-cpu-credit-balance-alarm-jc" # Name of the alarm
#   alarm_description         = "Alarm when CPU Credit Balance is below 1" # Description of the alarm
#   namespace                 = "AWS/RDS" # Namespace for RDS metrics
#   metric_name               = "CPUCreditBalance" # Metric to monitor
#   dimensions = {
#     DBInstanceIdentifier = aws_db_instance.default.identifier # DB instance identifier
#   }
#   statistic                = "Average" # Statistic type to use for the metric
#   period                   = 300 # Period in seconds (5 minutes)
#   evaluation_periods       = 1 # Number of periods to evaluate
#   threshold                = 1 # The threshold value for the alarm
#   comparison_operator      = "GreaterThanThreshold" # Condition to trigger the alarm
#   alarm_actions            = [aws_sns_topic.db-topic.arn] # List of actions to take when the alarm is triggered (e.g., SNS topic)
#   ok_actions               = [aws_sns_topic.db-topic.arn] # List of actions to take when the alarm state is OK
#   insufficient_data_actions = [aws_sns_topic.db-topic.arn] # List of actions to take when there is insufficient data
#
#   depends_on = [aws_sns_topic.db-topic, aws_sns_topic_subscription.email_subscription]
# }
#
# resource "aws_cloudwatch_metric_alarm" "rds_low_memory_alarm" {
#   alarm_name          = "RDSLowMemoryAlarm-JC"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = 1
#   metric_name         = "FreeableMemory"
#   namespace           = "AWS/RDS"
#   period              = 300  # 5 minutes
#   statistic           = "Average"
#   threshold           = 1073741824  # 1 GB in bytes
#   alarm_description   = "Alarm when RDS instance freeable memory is below 1GB (approx. 10% of total memory for many instance types)."
#   actions_enabled     = true
#   alarm_actions       = [aws_sns_topic.db-topic.arn]
#   ok_actions          = [aws_sns_topic.db-topic.arn]
#   insufficient_data_actions = [aws_sns_topic.db-topic.arn]
#
#   dimensions = {
#     DBInstanceIdentifier = aws_db_instance.default.identifier
#   }
#
#   treat_missing_data = "breaching"
# }
#
# resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization_alarm" {
#   alarm_name                = "rds-cpu-utilization-alarm-jc" # Name of the alarm
#   alarm_description         = "Alarm when CPU Utilization is above 80%" # Description of the alarm
#   namespace                 = "AWS/RDS" # Namespace for RDS metrics
#   metric_name               = "CPUUtilization" # Metric to monitor
#   dimensions = {
#     DBInstanceIdentifier = aws_db_instance.default.identifier # DB instance identifier
#   }
#   statistic                = "Average" # Statistic type to use for the metric
#   period                   = 300 # Period in seconds (5 minutes)
#   evaluation_periods       = 1 # Number of periods to evaluate
#   threshold                = 15 # The threshold value for the alarm (80% CPU utilization)
#   comparison_operator      = "GreaterThanThreshold" # Condition to trigger the alarm
#   alarm_actions            = [aws_sns_topic.db-topic.arn] # List of actions to take when the alarm is triggered (e.g., SNS topic)
#   ok_actions               = [aws_sns_topic.db-topic.arn] # List of actions to take when the alarm state is OK
#   insufficient_data_actions = [aws_sns_topic.db-topic.arn] # List of actions to take when there is insufficient data
#
#   depends_on = [aws_sns_topic.db-topic, aws_sns_topic_subscription.email_subscription]
# }
#
#
# resource "aws_sns_topic" "db-topic" {
#   name = "db-topic-jc"
# }
#
# resource "aws_sns_topic_subscription" "email_subscription" {
#   topic_arn = aws_sns_topic.db-topic.arn
#   protocol  = "email"
#   endpoint  = local.db_credentials_jc.email
# }


