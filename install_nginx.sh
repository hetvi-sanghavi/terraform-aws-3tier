#!/bin/bash
yum update -y
amazon-linux-extras install epel -y
yum install -y nginx
systemctl start nginx
echo "Hello World from $(hostname -f)" > /usr/share/nginx/html/index.html