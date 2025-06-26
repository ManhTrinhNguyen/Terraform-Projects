#!/bin/bash

sudo dnf update -y ## Update Server 

sudo dnf install -y docker ## Install Docker  

sudo systemctl start docker

sudo systemctl enable docker  

sleep 5 # Wait for Docker to be fully ready

sudo usermod -aG docker ec2-user 

sudo dnf install -y docker-compose-plugin 
