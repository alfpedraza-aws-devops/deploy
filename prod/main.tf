###############################################################################
# Create the PROD environment                                                 #
###############################################################################

provider "aws" {
  version = "~> 2.7"
  region = var.region_name
}

terraform {
  backend "s3" { }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = join("-", [var.account_id, var.project_name, "vpc-terraform-state"])
    key    = "terraform.tfstate"
    region = var.region_name
  }
}

module "terraform_state" {
  source = "../modules/environment"
  account_id = var.account_id
  region_name = var.region_name
  project_name = var.project_name
  environment_name = "prod"
  private_subnet_cidr_block = data.terraform_remote_state.vpc.outputs.private_prod_subnet_cidr_block
}