# ----------------------------------------------------------------------------#
# Create a launch configuration for the Kubernetes worker node instances      #
# This launch configuration will be used in the cluster autoscale group       #
# ----------------------------------------------------------------------------#

resource "aws_launch_configuration" "node" {
  name_prefix          = "${var.project_name}-private-${var.environment_name}-node-"
  image_id             = data.aws_ami.cluster_image.id
  instance_type        = var.node_instance_type
  key_name             = data.terraform_remote_state.vpc.outputs.key_name
  security_groups      = [aws_security_group.node.id]
  iam_instance_profile = aws_iam_instance_profile.node.name
  user_data            = join("\n\n", [
                         file("${path.module}/scripts/metadata.sh"),
                         "GLOBAL_CLUSTER_NAME=${var.project_name}",
                         "GLOBAL_MASTER_NAME=${var.project_name}-private-${var.environment_name}-master",
                         file("${path.module}/scripts/dependencies.sh"),
                         file("${path.module}/scripts/kubelet.sh"),
                         file("${path.module}/scripts/nodes/join-cluster.sh"),
                         file("${path.module}/scripts/nodes/install-plugins.sh"),
                         file("${path.module}/scripts/nodes/main.sh")])
  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------------------------------------------#
# Create an autoscaling group to create Kubernetes worker nodes               #
# ----------------------------------------------------------------------------#

resource "aws_autoscaling_group" "nodes" {
  name                 = "${var.project_name}-private-${var.environment_name}-nodes"
  launch_configuration = aws_launch_configuration.node.name
  min_size             = var.worker_node_count
  max_size             = var.worker_node_count
  vpc_zone_identifier  = [aws_subnet.private_environment.id]
  
  tags = concat(data.null_data_source.common_tags.*.outputs, list(
    map("key", "Name", "value", "${var.project_name}-private-${var.environment_name}-node", "propagate_at_launch", true),
    map("key", "kubernetes.io/cluster/${var.project_name}", "value", "owned", "propagate_at_launch", true),
    map("key", "k8s.io/cluster-autoscaler/enabled", "value", "1", "propagate_at_launch", true)
  ))
  lifecycle {
    create_before_destroy = true
  }
}

# Export the local.common_tags values as the type that the autoscaling group
# tags property requires.
data "null_data_source" "common_tags" {
  count = "${length(keys(local.common_tags))}"
  inputs = {
    key                 = "${element(keys(local.common_tags), count.index)}"
    value               = "${element(values(local.common_tags), count.index)}"
    propagate_at_launch = true
  }
}

# ----------------------------------------------------------------------------#
# Create the firewall rules for the Kubernetes master node                    #
# ----------------------------------------------------------------------------#

resource "aws_security_group" "node" {
  name        = "${var.project_name}-private-${var.environment_name}-node"
  description = "Allows access to the Worker nodes."
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
    
  ingress {
    description     = "All access from master node"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.master.id]
  }

  ingress {
    description     = "All access from worker nodes"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    self            = true
  }

  ingress {
    description     = "SSH Port"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.vpc.outputs.nat_gateway_security_group_id]
  }

  ingress {
    description     = "Kubernetes Kubelet Port"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.master.id]
  }

  ingress {
    description     = "Kubernetes Kubelet ReadOnly Port"
    from_port       = 10255
    to_port         = 10255
    protocol        = "tcp"
    security_groups = [aws_security_group.master.id]
  }

  egress {
    description     = "All access"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-private-${var.environment_name}-node"
  ))
}