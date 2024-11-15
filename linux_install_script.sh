#!/bin/bash

# Update the package list
echo "Updating package list..."
sudo apt update

# Add Ansible PPA repository
echo "Adding Ansible PPA repository..."
sudo add-apt-repository --yes --update ppa:ansible/ansible

# Install Ansible
echo "Installing Ansible..."
sudo apt install -y ansible

# Install Python3 and PIP
echo "Installing Ansible..."
sudo apt install python3
sudo apt install python3-pip

# Install PywWinRM
echo "Installing PyWinRM"
pip3 install pywinrm

echo "Ansible installation complete."

