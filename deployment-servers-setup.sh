#!/bin/bash
# Hardware requirements: port 8080(application port), 9100 (node-exporter port) should be allowed at firewall level.
# setup for the ansible configuration
sudo apt update –y
sudo useradd ansible
sudo echo "ansible:ansible" | chpasswd
sudo sed -i "s/.*PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo sed -i 's/.*#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sudo usermod -aG wheel ansible
sudo service sshd restart

# tomcat installations
sudo apt-get install tomcat8.5 -y
sudo systemctl enable tomcat
sudo systemctl start tomcat

# node-exporter installations
sudo useradd --no-create-home node_exporter

wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64

# setup the node-exporter dependencies
sudo apt-get install git -y
sudo git clone -b installations https://github.com/clemusgo9981/devops-fully-automated.git /tmp/devops-fully-automated
sudo cp /tmp/devops-fully-automated/prometheus-setup-dependencies/node-exporter.service /etc/systemd/system/node-exporter.service

sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
sudo systemctl status node-exporter
