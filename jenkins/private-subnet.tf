# ----------------------------------------------------------------------------#
# Create the private subnet where the Jenkins server will be hosted           #
# ----------------------------------------------------------------------------#

resource "aws_subnet" "private_jenkins" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  availability_zone = local.vpc_availability_zone
  cidr_block        = data.terraform_remote_state.vpc.outputs.private_jenkins_subnet_cidr_block

  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-private-jenkins",
    "kubernetes.io/cluster/${var.project_name}", "owned",
    "kubernetes.io/role/internal-elb", "1"
  ))
}

# ----------------------------------------------------------------------------#
# Create a route table for the private subnet towards the NAT gateway         #
# ----------------------------------------------------------------------------#

resource "aws_route_table" "private_jenkins" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = data.terraform_remote_state.vpc.outputs.nat_gateway_id
  }

  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-private-jenkins"
  ))
}

# ----------------------------------------------------------------------------#
# Associate the route table with the private subnet                           #
# ----------------------------------------------------------------------------#

resource "aws_route_table_association" "private_jenkins" {
  subnet_id      = aws_subnet.private_jenkins.id
  route_table_id = aws_route_table.private_jenkins.id
}