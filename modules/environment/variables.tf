# ----------------------------------------------------------------------------#
# Required Parameters                                                         #
# ----------------------------------------------------------------------------#

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

variable "environment_name" {
  description = "The name of the environment where the resources will be created"
  type = string
}

variable "private_subnet_cidr_block" {
  description = "The CIDR block assigned to the private subnet of this environment"
  type = string
}

# ----------------------------------------------------------------------------#
# Optional Parameters                                                         #
# ----------------------------------------------------------------------------#

variable "node_instance_type" {
  description = "The instance type for the Kubernetes nodes"
  type = string
  default = "t2.medium"
}

variable "worker_node_count" {
  description = "The number of worker nodes for the Kubernetes cluster"
  type = number
  default = 1
}

locals {
    vpc_availability_zone = join("", [var.region_name, "a"])
    common_tags = {
        ApplicationId = var.project_name
        EnvironmentId = var.environment_name
    }
}