resource "aws_subnet" "private" {
    vpc_id            = aws_vpc.vpc.id
    availability_zone = local.vpc_availability_zone
    cidr_block        = var.private_subnet_cidr_block

    tags = merge(local.common_tags, map(
        "Name", "${var.cluster_name}-private",
        "kubernetes.io/cluster/${var.cluster_name}", "owned",
        "kubernetes.io/role/internal-elb", "1"
    ))
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block  = "0.0.0.0/0"
        instance_id = aws_instance.nat_gateway.id
    }

    tags = merge(local.common_tags, map(
        "Name", "${var.cluster_name}-private"
    ))
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}