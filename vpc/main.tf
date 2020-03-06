###############################################################################
# Create the network infrastructure                                           #
###############################################################################

provider "aws" {
  version = "~> 2.7"
  region = var.region_name
}

terraform {
  backend "s3" {
    bucket         = var.account_id + "-" + var.project_name + "-bucket-vpc"
    key            = "terraform.tfstate"
    region         = var.region_name
    dynamodb_table = var.account_id + "-" + var.project_name + "-table-vpc"
    encrypt        = true
  }
}