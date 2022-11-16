#!/bin/bash
#sudo vi /etc/yum.repos.d/nginx.repo
sudo echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/\$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo
sudo yum update -y
sudo yum install -y nginx
sudo systemctl start nginx && sudo systemctl enable nginx

