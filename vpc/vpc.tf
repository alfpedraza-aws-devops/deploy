# ----------------------------------------------------------------------------#
# Create the AWS VPC where the project will be hosted.                        #
# ----------------------------------------------------------------------------#

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, map(
    "Name", var.project_name,
    "kubernetes.io/cluster/${var.project_name}", "shared"
  ))
}

# ----------------------------------------------------------------------------#
# Create the Internet Gateway where all the external network packets will go  #
# ----------------------------------------------------------------------------#

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, map(
    "Name", "internet-gateway",
  ))
}

# ----------------------------------------------------------------------------#
# Create the key pair that will be used to secure the AWS instances           #
# ----------------------------------------------------------------------------#

resource "aws_key_pair" "project" {
  key_name   = var.project_name
  public_key = var.project_public_key

  tags = merge(local.common_tags, map(
    "Name", var.project_name
  ))
}