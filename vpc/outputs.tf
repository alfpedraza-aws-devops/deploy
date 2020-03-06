# ----------------------------------------------------------------------------#
# Output values                                                               #
# ----------------------------------------------------------------------------#

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The id of the project VPC"
}

output "private_jenkins_subnet_cidr_block" {
  value       = var.private_jenkins_subnet_cidr_block
  description = "The CIDR block assigned to the private jenkins subnet"
}

output "private_dev_subnet_cidr_block" {
  value       = var.private_dev_subnet_cidr_block
  description = "The CIDR block assigned to the private dev subnet"
}

output "private_prod_subnet_cidr_block" {
  value       = var.private_prod_subnet_cidr_block
  description = "The CIDR block assigned to the private prod subnet"
}

output "nat_gateway_id" {
  value       = aws_instance.nat_gateway.id
  description = "The id of the NAT Gateway instance"
}

output "key_name" {
  value       = aws_key_pair.key_pair.key_name
  description = "The name of the Key Pair needed to secure the access to the instances"
}