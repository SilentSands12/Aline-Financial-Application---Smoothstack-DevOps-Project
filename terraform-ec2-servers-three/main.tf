# Define the required Terraform version and providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0"
    }
  }
  required_version = ">= 1.3.2" # Ensure Terraform version is at least 1.3.2
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Set the AWS region to use
}

module "networking" {
  source          = "./modules/networking" # Path to the networking module
}

# Define an Ubuntu instance
resource "aws_instance" "ubuntu" {
  ami           = "ami-00a0e0b890ae17d65" # Ubuntu AMI ID
  instance_type = "t2.micro"
  key_name      = "key-pair-jc" # Key pair for SSH access
  vpc_security_group_ids = [
    module.networking.elastic-security-group
  ]
  subnet_id = module.networking.subnet_id

  tags = {
    Name = "ubuntu-instance-jc"
  }

}

# Define a RHEL instance
resource "aws_instance" "rhel" {
  ami           = "ami-0583d8c7a9c35822c" # RHEL AMI ID
  instance_type = "t2.micro"
  key_name      = "key-pair-jc" # Key pair for SSH access
  vpc_security_group_ids = [
    module.networking.elastic-security-group
  ]
  subnet_id = module.networking.subnet_id

  tags = {
    Name = "rhel-instance-jc"
  }

  # User data script to configure the RHEL instance on launch
  user_data = <<-EOF
    #!/bin/bash
    # Ensure the system is updated
    sudo yum update -y

    # Install necessary packages
    sudo yum install -y python3-pip

    # Update repository URLs to use the correct region
    sudo find /etc/yum.repos.d/ -type f -name "*.repo" -exec sed -i 's|https://rhui.REGION.aws.ce.redhat.com|https://rhui.us-east-1.aws.ce.redhat.com|g' {} +

    # Clean and update yum cache
    sudo dnf clean all
    sudo dnf makecache
  EOF

  # Define SSH connection details for the RHEL instance
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key-pair/key-pair-jc.pem")
    host        = self.public_ip
  }
}

# Define an Amazon Linux instance
resource "aws_instance" "amazon_linux" {
  ami           = "ami-0427090fd1714168b" # Amazon Linux AMI ID
  instance_type = "t2.micro"
  key_name      = "key-pair-jc" # Key pair for SSH access
  vpc_security_group_ids = [
    module.networking.elastic-security-group
  ]
  subnet_id = module.networking.subnet_id

  # User data script to configure the Amazon Linux instance on launch
  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install -y python3
              sudo yum install -y python3-pip

              sudo dnf install -y fontawesome-fonts

              # Create the EPEL repository configuration file
              echo '[epel]
              name=Extra Packages for Enterprise Linux 9 - x86_64
              baseurl=https://download.fedoraproject.org/pub/epel/9/Everything/\$basearch/
              enabled=1
              gpgcheck=1
              gpgkey=https://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-9' | sudo tee /etc/yum.repos.d/epel.repo > /dev/null

              # Update the repository cache
              sudo dnf makecache
              EOF

  tags = {
    Name = "amazon-linux-instance-jc"
  }
}

# Output the public IP address of the Amazon Linux instance
output "amazon_linux_public_ip" {
  value = aws_instance.amazon_linux.public_ip
  description = "Public IP address of the Amazon Linux instance"
}

# Output the public IP address of the RHEL instance
output "rhel_public_ip" {
  value = aws_instance.rhel.public_ip
  description = "Public IP address of the RHEL instance"
}

# Output the public IP address of the Ubuntu instance
output "ubuntu_public_ip" {
  value = aws_instance.ubuntu.public_ip
  description = "Public IP address of the Ubuntu instance"
}
