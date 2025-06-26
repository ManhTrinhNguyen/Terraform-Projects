#!/bin/bash

export IMAGE_NAME=$1
export ECR_USERNAME=$2
export ECR_PASS=$3
export ECR_URL=$4

echo $ECR_PASS | docker login --username $ECR_USERNAME --password-stdin $ECR_URL

docker-compose -f docker-compose.yaml up --detach 

echo "Success deploy my java app"