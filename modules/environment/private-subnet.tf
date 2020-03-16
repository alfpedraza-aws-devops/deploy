# ----------------------------------------------------------------------------#
# Create the private subnet where the Kubernetes cluster will be hosted       #
# ----------------------------------------------------------------------------#

resource "aws_subnet" "private_environment" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  availability_zone = local.vpc_availability_zone
  cidr_block        = var.private_subnet_cidr_block
  
  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-private-${var.environment_name}",
    "kubernetes.io/cluster/${var.project_name}", "owned",
    "kubernetes.io/role/internal-elb", "1"
  ))
}

# ----------------------------------------------------------------------------#
# Create a route table for the private subnet towards the NAT gateway         #
# ----------------------------------------------------------------------------#

resource "aws_route_table" "private_environment" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = data.terraform_remote_state.vpc.outputs.nat_gateway_id
  }
  
  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-private-${var.environment_name}"
  ))
}

# ----------------------------------------------------------------------------#
# Associate the route table with the private subnet                           #
# ----------------------------------------------------------------------------#

resource "aws_route_table_association" "private_environment" {
  subnet_id      = aws_subnet.private_environment.id
  route_table_id = aws_route_table.private_environment.id
}
