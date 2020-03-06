###############################################################################
# Create the network infrastructure                                           #
###############################################################################

provider "aws" {
  version = "~> 2.7"
  region = var.region_name
}

terraform {
  backend "s3" { }
}