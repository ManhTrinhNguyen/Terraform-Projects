#!/bin/bash

PATH=$PATH:/usr/local/bin

sudo yum update -y ## Update Server 

sudo yum install -y docker ## Install Docker  

sudo systemctl enable docker

sudo systemctl start docker ## Start Docker 

sudo usermod -aG docker ec2-user 

sleep 10s

### Download Docker compose 

sudo curl -SL "https://github.com/docker/compose/releases/download/v2.35.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose