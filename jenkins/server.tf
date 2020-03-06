resource "aws_instance" "master" {
    subnet_id              = aws_subnet.private.id
    ami                    = data.aws_ami.cluster_image.id
    instance_type          = var.cluster_instance_type
    key_name               = aws_key_pair.cluster.key_name
    vpc_security_group_ids = [aws_security_group.master.id]
    user_data              = join("", [
                             file("scripts/metadata.sh"),
                             "GLOBAL_CLUSTER_NAME=${var.cluster_name}",
                             file("scripts/dependencies.sh"),
                             file("scripts/kubelet.sh"),
                             file("scripts/master/start-cluster.sh"),
                             file("scripts/master/share-join-data.sh"),
                             file("scripts/master/install-plugins.sh"),
                             file("scripts/master/main.sh")])
    iam_instance_profile   = aws_iam_instance_profile.master.name

    depends_on = [aws_instance.nat_gateway]
    tags = merge(local.common_tags, map(
        "Name", "master",
        "kubernetes.io/cluster/${var.cluster_name}", "owned"
    ))

    lifecycle {
        ignore_changes = [tags]
    }
}

data "aws_ami" "cluster_image" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }
}

resource "aws_security_group" "master" {
    name        = "master"
    description = "Allows access to the Master node."
    vpc_id      = aws_vpc.vpc.id

    tags = merge(local.common_tags, map(
        "Name", "master"
    ))
}

# Declare the rules outside of the security group to avoid cycles.
resource "aws_security_group_rule" "master_ingress_01" {
    security_group_id        = aws_security_group.master.id
    type                     = "ingress"
    from_port                = 0
    to_port                  = 65535
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "master_ingress_02" {
    security_group_id        = aws_security_group.master.id
    type                     = "ingress"
    from_port                = 6443
    to_port                  = 6443
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "master_ingress_03" {
    security_group_id        = aws_security_group.master.id
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.nat_gateway.id
}

resource "aws_security_group_rule" "master_ingress_04" {
    security_group_id        = aws_security_group.master.id
    type                     = "ingress"
    from_port                = 6443
    to_port                  = 6443
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.nat_gateway.id
}

resource "aws_security_group_rule" "master_ingress_05" {
    security_group_id        = aws_security_group.master.id
    type                     = "ingress"
    from_port                = 53
    to_port                  = 53
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "master_ingress_06" {
    security_group_id        = aws_security_group.master.id
    type                     = "ingress"
    from_port                = 53
    to_port                  = 53
    protocol                 = "udp"
    source_security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "master_egress_01" {
    security_group_id = aws_security_group.master.id
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
}