###############################################################################
# Create a Kubernetes cluster with one master and one worker node             #
###############################################################################

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = join("-", [var.account_id, var.project_name, "vpc-terraform-state"])
    key    = "terraform.tfstate"
    region = var.region_name
  }
}

data "terraform_remote_state" "jenkins" {
  backend = "s3"
  config = {
    bucket = join("-", [var.account_id, var.project_name, "jenkins-terraform-state"])
    key    = "terraform.tfstate"
    region = var.region_name
  }
}