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

variable "terraform_module" {
  default = "jenkins"
}