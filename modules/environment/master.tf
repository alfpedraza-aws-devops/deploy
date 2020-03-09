# ----------------------------------------------------------------------------#
# Get the AMI for the Kubernetes nodes                                        #
# ----------------------------------------------------------------------------#

data "aws_ami" "cluster_image" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

# ----------------------------------------------------------------------------#
# Create the Kubernetes master node in the private environment subnet         #
# ----------------------------------------------------------------------------#

resource "aws_instance" "master" {
  subnet_id              = aws_subnet.private_environment.id
  ami                    = data.aws_ami.cluster_image.id
  instance_type          = var.node_instance_type
  key_name               = data.terraform_remote_state.vpc.outputs.key_name
  vpc_security_group_ids = [aws_security_group.master.id]
  iam_instance_profile   = aws_iam_instance_profile.master.name
  user_data              = join("\n\n", [
                           file("${path.module}/scripts/metadata.sh"),
                           "GLOBAL_CLUSTER_NAME=${var.project_name}",
                           "GLOBAL_ENVIRONMENT_NAME=${var.environment_name}",
                           "GLOBAL_NODE_ROLE_NAME=${aws_iam_role.node.name}",
                           "GLOBAL_CLUSTER_AUTOSCALER_ROLE_NAME=${aws_iam_role.cluster_autoscaler.name}",
                           "GLOBAL_MASTER_NAME=${var.project_name}-private-${var.environment_name}-master",
                           file("${path.module}/scripts/dependencies.sh"),
                           file("${path.module}/scripts/kubelet.sh"),
                           file("${path.module}/scripts/master/start-cluster.sh"),
                           file("${path.module}/scripts/master/share-join-data.sh"),
                           file("${path.module}/scripts/master/install-plugins.sh"),
                           file("${path.module}/scripts/master/main.sh")])
  depends_on               = [aws_iam_role.node,
                              aws_iam_role.cluster_autoscaler]

  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-private-${var.environment_name}-master",
    "kubernetes.io/cluster/${var.project_name}", "owned"
  ))
  
  lifecycle {
    ignore_changes = [tags]
  }
}

# ----------------------------------------------------------------------------#
# Create the firewall rules for the Kubernetes master node                    #
# ----------------------------------------------------------------------------#

resource "aws_security_group" "master" {
  name        = "${var.project_name}-private-${var.environment_name}-master"
  description = "Allows access to the Master node."
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  
  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-private-${var.environment_name}-master"
  ))
}

# ----------------------------------------------------------------------------#
# Declare the security group rules outside of the master security group to    #
# avoid circular references with the node security group.                     #
# ----------------------------------------------------------------------------#

resource "aws_security_group_rule" "master_ingress_01" {
  security_group_id        = aws_security_group.master.id
  type                     = "ingress"
  description              = "All access from worker nodes"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "master_ingress_02" {
  security_group_id        = aws_security_group.master.id
  type                     = "ingress"
  description              = "Kubernetes API Server Port"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
}
  
resource "aws_security_group_rule" "master_ingress_03" {
  security_group_id        = aws_security_group.master.id
  type                     = "ingress"
  description              = "SSH Port"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.vpc.outputs.nat_gateway_security_group_id
}
  
resource "aws_security_group_rule" "master_ingress_04" {
  security_group_id        = aws_security_group.master.id
  type                     = "ingress"
  description              = "Kubernetes API Server Port"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.vpc.outputs.nat_gateway_security_group_id
}
  
resource "aws_security_group_rule" "master_ingress_05" {
  security_group_id        = aws_security_group.master.id
  type                     = "ingress"
  description              = "DNS Port"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
}
  
resource "aws_security_group_rule" "master_ingress_06" {
  security_group_id        = aws_security_group.master.id
  type                     = "ingress"
  description              = "DNS Port"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  source_security_group_id = aws_security_group.node.id
}
  
resource "aws_security_group_rule" "master_egress_01" {
  security_group_id        = aws_security_group.master.id
  type                     = "egress"
  description              = "All access"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
}