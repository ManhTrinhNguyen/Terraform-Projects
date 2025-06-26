#!/bin/bash

sudo yum update -y ## Update Server 

sudo yum install -y docker ## Install Docker  

sudo systemctl enable docker

sudo systemctl start docker ## Start Docker 

sudo usermod -aG docker ec2-user 

sleep 10s

### Download Docker compose 

sudo curl -SL "https://github.com/docker/compose/releases/download/v2.35.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

sleep 10s

export IMAGE_NAME=$1
export ECR_USERNAME=$2
export ECR_PASS=$3
export ECR_URL=$4

echo $ECR_PASS | docker login --username $ECR_USERNAME --password-stdin $ECR_URL

docker-compose -f docker-compose.yaml up --detach 

echo "Success deploy my java app"