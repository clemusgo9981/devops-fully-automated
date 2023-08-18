#!/bin/bash
# Hardware requirements: port 8080(jenkins), 9100 (node-exporter) should be allowed at firewall level

# Update repositories
sudo apt update && sudo apt upgrade -y

# Installing Jenkins
sudo apt install wget openjdk-11-jdk -y
sudo wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
echo "deb https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install jenkins -y
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Installing Git
sudo apt install git -y

# Java installation (Java 11 is already installed above for Jenkins)

# Installing Ansible
sudo apt install ansible python3-pip -y
sudo useradd ansible
echo ansible:ansible | sudo chpasswd
sudo sed -i "s/.*#host_key_checking = False/host_key_checking = False/g" /etc/ansible/ansible.cfg
sudo sed -i "s/.*#enable_plugins = host_list, virtualbox, yaml, constructed/enable_plugins = vmware_vm_inventory/g" /etc/ansible/ansible.cfg
sudo ansible-galaxy collection install

# node-exporter installations
sudo useradd --no-create-home node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64

# setup the node-exporter dependencies
git clone -b installations https://github.com/cvamsikrishna11/devops-fully-automated.git /tmp/devops-fully-automated
sudo cp /tmp/devops-fully-automated/prometheus-setup-dependencies/node-exporter.service /etc/systemd/system/node-exporter.service

sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
sudo systemctl status node-exporter

# Setup Terraform
sudo apt install -y software-properties-common
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install terraform -y
