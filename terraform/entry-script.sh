#!/bin/bash

sudo yum update -y ## Update Server 

sudo yum install -y docker ## Install Docker  

sudo systemctl enable docker

sudo systemctl start docker ## Start Docker 

sleep 5 # Wait for Docker to be fully ready

sudo usermod -aG docker ec2-user 

docker run -d -p 8080:80 nginx