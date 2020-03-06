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

variable "public_subnet_cidr_block" {
  description = "The CIDR block assigned to the public subnet"
  type = string
  default = "10.0.0.0/20"
}

variable "private_jenkins_subnet_cidr_block" {
  description = "The CIDR block assigned to the private jenkins subnet"
  type = string
  default = "10.0.16.0/20"
}

variable "private_dev_subnet_cidr_block" {
  description = "The CIDR block assigned to the private dev subnet"
  type = string
  default = "10.0.32.0/20"
}

variable "private_prod_subnet_cidr_block" {
  description = "The CIDR block assigned to the private prod subnet"
  type = string
  default = "10.0.48.0/20"
}

variable "nat_gateway_instance_type" {
  description = "The instance type for the public NAT gateway machine"
  type = string
  default = "t2.micro"
}

variable "project_public_key" {
  description = "The public key used to create a key pair"
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0ToS1Bn1T77Mo4RHfmZuXY+bhHGM5cDIb/qVUBz2xw/vNj9NlRb4h+BxJ8/OMW7b5JizKcfkoQZQRj8/iHyGJbYpP3EQbZi5srpf+ezLAKl/RGgFz8Kv1Ig/IsRBYXlmvJfEoZyWl89gyayT5uRm+hQW2BCLURmpzsKSj4p2cpi+Ompkiw2L7EcmNBuNgRYkHytht8WVF0nEXwn7NkBErkSV+1E3j9G02ARhiKYYSWwdlJY7lNcSUZKqlvvHA5967NmkIOVnd5XVViq+oaDqFanLgSun3iyW553Kk6xzoVgkcOt7YBg37fPwcW2/rclsQK6prDgmOavhZdhgPBThZpou7TQUkrBdxqLUeHU5A1LPj3gU7lBAob+89o0UStiLI5vvb7ReKa/StrX6bemr9Ru7JZovQytePrukzGTqEClCz/Q2MznSa94R1I8ymX34SvodiSLv9eG3OlW26qT1kTT2VmQyItTtnfvr0XNPlY83j/r4Jp5+pOAfaQWjeey4OCTgXpG4xtR5OBZxqDJAFhc/SKnRLyZnzbaILl8v7Yme8pH7Tq9Bt+gYfUf2n36yMuYSjkthAm4VcLgbLyHcP6AFMzQbNPrQbGvJ/rEz6lHWltrM9x8d3n4yPJnWpFwcjTfzvBlvZ7BqA8mapxTBhAYvrMLf0TM23Ebu0NjM/0w== alfredo.pedraza.figueroa.84@gmail.com"
}

locals {
    vpc_availability_zone = join("", [var.region_name, "a"])
    common_tags = {
        ApplicationId = var.project_name
    }
}