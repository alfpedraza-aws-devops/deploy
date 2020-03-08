# ----------------------------------------------------------------------------#
# Create the IAM role for the Kubernetes cluster autoscaller service          #
# ----------------------------------------------------------------------------#

resource "aws_iam_role" "cluster_autoscaler" {
  name               = "${var.project_name}-${var.region_name}-${var.environment_name}-cluster-autoscaler"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"${aws_iam_role.node.arn}\"},\"Action\":\"sts:AssumeRole\"}]}"
}

resource "aws_iam_role_policy" "cluster_autoscaler_policy" {
  name   = "autoscaler"
  role   = aws_iam_role.cluster_autoscaler.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"ClusterAutoscalerTaggedResourcesWritable\",\"Effect\":\"Allow\",\"Action\":[\"autoscaling:DescribeAutoScalingGroups\",\"autoscaling:DescribeAutoScalingInstances\",\"autoscaling:DescribeTags\",\"autoscaling:SetDesiredCapacity\",\"autoscaling:TerminateInstanceInAutoScalingGroup\"],\"Resource\":\"*\"}]}"
}
