###############################################################################
# Create the S3 bucket and DynamoDB table that will hold the terraform state  #
###############################################################################

provider "aws" {
  version = "~> 2.7"
  region = var.region_name
}

module "terraform_state" {
  source = "../../modules/terraform-state"
  region_name = var.region_name
  bucket_name = var.account_id + "-" + var.project_name + "-bucket-" + var.terraform_module
  table_name = var.account_id + "-" + var.project_name + "-table-" + var.terraform_module
}