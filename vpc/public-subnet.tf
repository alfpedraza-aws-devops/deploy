# ----------------------------------------------------------------------------#
# Create the public subnet where the NAT gateway will be hosted               #
# ----------------------------------------------------------------------------#

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = local.vpc_availability_zone
  cidr_block              = var.public_subnet_cidr_block
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-public",
    "kubernetes.io/cluster/${var.project_name}", "owned",
    "kubernetes.io/role/internal-elb", "1"
  ))
}

# ----------------------------------------------------------------------------#
# Create a route table for the public subnet towards the IGW                  #
# ----------------------------------------------------------------------------#

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-public"
  ))
}

# ----------------------------------------------------------------------------#
# Associate the route table with the public subnet                            #
# ----------------------------------------------------------------------------#

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}