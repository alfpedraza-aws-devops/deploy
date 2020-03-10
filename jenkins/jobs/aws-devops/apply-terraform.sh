#!/bin/bash

# Script parameters
ACCOUNT_ID=$1
REGION_NAME=$2
PROJECT_NAME=$3
ENVIRONMENT_NAME=$4

# Local variables
BUCKET_NAME=$ACCOUNT_ID-$PROJECT_NAME-$ENVIRONMENT_NAME-terraform-state
TABLE_NAME=$ACCOUNT_ID-$PROJECT_NAME-$ENVIRONMENT_NAME-terraform-lock

# Initialize Terraform
terraform init \
    -input=false \
    -backend-config="bucket=$BUCKET_NAME" \
    -backend-config="key=terraform.tfstate" \
    -backend-config="region=$REGION_NAME" \
    -backend-config="dynamodb_table=$TABLE_NAME" \
    -backend-config="encrypt=true"

# Apply the changes
terraform apply \
    -input=false \
    -lock=true \
    -auto-approve \
    -var "account_id=$ACCOUNT_ID" \
    -var "region_name=$REGION_NAME" \
    -var "project_name=$PROJECT_NAME"