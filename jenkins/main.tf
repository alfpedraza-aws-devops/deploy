###############################################################################
# Create the Jenkins subnet and the Jenkins server                            #
###############################################################################

provider "aws" {
  version = "~> 2.7"
  region = var.region_name
}

provider "external" {
  version = "~> 1.2"
}

terraform {
  backend "s3" { }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = join("-", [var.account_id, var.project_name, "bucket-vpc"])
    key    = "terraform.tfstate"
    region = var.region_name
  }
}
