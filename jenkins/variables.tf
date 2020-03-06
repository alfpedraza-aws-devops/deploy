###############################################################################
# Required Parameters                                                         #
###############################################################################

variable "account_id" {
  description = "The AWS account id running this example project"
  type = string
}

variable "region_name" {
  description = "The name of the region where the resources will be created"
  type = string
}

variable "project_name" {
  description = "The name of this aws-devops example project"
  type = string
}

###############################################################################
# Optional Parameters                                                         #
###############################################################################

variable "vpc_cidr_block" {
  description = "The CIDR block assigned to the VPC"
  type = string
  default = "10.0.0.0/16"
}

locals {
    vpc_availability_zone = join("", [var.region_name, "a"])
    common_tags = {
        ApplicationId = var.project_name
    }
}