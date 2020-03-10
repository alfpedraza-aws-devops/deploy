#!/bin/bash

# Script parameters
REGION_NAME=$1
DOCKER_REPOSITORY_URL=$2
RAW_IMAGE_NAME=$3
RAW_IMAGE_TAG=$4
BUILD_ID=$5

# Local variables
IMAGE_TAG=$RAW_IMAGE_TAG.$BUILD_ID
IMAGE_NAME=$DOCKER_REPOSITORY_URL/$RAW_IMAGE_NAME:$IMAGE_TAG


# Build the image and push it to the docker repository 
aws ecr get-login-password --region $REGION_NAME | \
    docker login --username AWS --password-stdin $DOCKER_REPOSITORY_URL
docker build -t $IMAGE_NAME .
docker push $IMAGE_NAME