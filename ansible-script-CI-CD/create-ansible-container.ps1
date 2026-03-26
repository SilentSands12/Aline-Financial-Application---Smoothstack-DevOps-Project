# Run Docker container with Ansible and execute the playbook
docker run -it --rm `
  --name ansible-container-jc `
  -v "C:/Users/Canal/OneDrive/Desktop/stuff/Python Projects/SmoothStacks/capstone-jenkins/ansible-creations:/ansible" `
  -v "C:/Users/Canal/OneDrive/Desktop:/key-pair" `
  -e ANSIBLE_CONFIG=/ansible/ansible.cfg `
  williamyeh/ansible:alpine3 /bin/sh -c "ansible-playbook -i /ansible/inventory.ini /ansible/elkstack-configs.yml"
