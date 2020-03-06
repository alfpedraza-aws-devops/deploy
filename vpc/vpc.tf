resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = merge(local.common_tags, map(
        "Name", var.cluster_name,
        "kubernetes.io/cluster/${var.cluster_name}", "shared"
    ))
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = merge(local.common_tags, map(
        "Name", "internet-gateway",
    ))
}

resource "aws_key_pair" "cluster" {
  key_name   = "cluster-key"
  public_key = var.cluster_public_key

  tags = merge(local.common_tags, map(
        "Name", "cluster-key"
    ))
}