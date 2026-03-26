#!/bin/bash

# Navigate to the Terraform configuration directory
cd "C:/Users/Canal/OneDrive/Desktop/stuff/Python Projects/SmoothStacks/capstone-jenkins/terraform-ec2-servers-three"

# Initialize Terraform apply
terraform init

# Run Terraform apply
terraform apply -auto-approve

# Run the Python script to generate the inventory and save it to inventory.ini
./dynamic_ansible_inventory_creation.py > "C:/Users/Canal/OneDrive/Desktop/stuff/Python Projects/SmoothStacks/capstone-jenkins/ansible-creations/inventory.ini"

