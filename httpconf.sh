#!/bin/bash

# Update the server
ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "sudo yum update -y";

# Install http server
ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "sudo yum install httpd";

# Start http services
ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "sudo systemctl start httpd";

# Enable http services
ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "sudo systemctl enable httpd";

# Insert data into index.html
ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "echo "Hello World" > /var/www/html/index.html"
