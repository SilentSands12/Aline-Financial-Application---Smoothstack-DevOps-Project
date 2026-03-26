#!/usr/bin/env python

import subprocess
import sys

def get_terraform_output(output_name):
    try:
        return subprocess.check_output(["terraform", "output", "-raw", output_name]).strip().decode()
    except subprocess.CalledProcessError as e:
        print(f"Error fetching output {output_name}: {e}", file=sys.stderr)
        return None

# Fetch Terraform outputs
amazon_linux_ip = get_terraform_output("amazon_linux_public_ip")
rhel_ip = get_terraform_output("rhel_public_ip")
ubuntu_ip = get_terraform_output("ubuntu_public_ip")

if amazon_linux_ip is None or rhel_ip is None or ubuntu_ip is None:
    print("One or more Terraform outputs could not be retrieved.", file=sys.stderr)
    sys.exit(1)

# Build the inventory in INI format
inventory_ini = f"""
# Inventory file for Ansible with details of managed hosts

# Section for Ubuntu instances
[ubuntu]
{ubuntu_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/key-pair/key-pair-jc.pem ansible_python_interpreter=/usr/bin/python3
# IP address of the Ubuntu instance. SSH user is 'ubuntu'. The private key for SSH authentication is located at /key-pair/key-pair-jc.pem.
# The Python 3 interpreter path is /usr/bin/python3.

# Section for RHEL instances
[rhel]
{rhel_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/key-pair/key-pair-jc.pem ansible_python_interpreter=/usr/bin/python3
# IP address of the RHEL instance. SSH user is 'ec2-user'. The private key for SSH authentication is located at /key-pair/key-pair-jc.pem.
# The Python 3 interpreter path is /usr/bin/python3.

# Section for Amazon Linux instances
[amazon_linux]
{amazon_linux_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/key-pair/key-pair-jc.pem ansible_python_interpreter=/usr/bin/python3
# IP address of the Amazon Linux instance. SSH user is 'ec2-user'. The private key for SSH authentication is located at /key-pair/key-pair-jc.pem. 
# The Python 3 interpreter path is /usr/bin/python3.

"""

# Print the INI inventory to stdout with UTF-8 encoding
sys.stdout.buffer.write(inventory_ini.strip().encode('utf-8'))
