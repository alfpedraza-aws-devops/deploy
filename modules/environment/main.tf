###############################################################################
# Create a Kubernetes cluster with one master and one worker node             #
###############################################################################

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = join("-", [var.account_id, var.project_name, "bucket-vpc"])
    key    = "terraform.tfstate"
    region = var.region_name
  }
}