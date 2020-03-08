# ----------------------------------------------------------------------------#
# Create instance profile that the worker node servers will hold              #
# ----------------------------------------------------------------------------#

resource "aws_iam_instance_profile" "node" {
  name =  "${var.project_name}-${var.region_name}-${var.environment_name}-node"
  role = aws_iam_role.node.name
}

# ----------------------------------------------------------------------------#
# Create the IAM role for the worker node servers                             #
# ----------------------------------------------------------------------------#

resource "aws_iam_role" "node" {
  name               = "${var.project_name}-${var.region_name}-${var.environment_name}-node"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
}

# ----------------------------------------------------------------------------#
# Define several policies that will be attached to the node role              #
# ----------------------------------------------------------------------------#

resource "aws_iam_role_policy" "node_instance" {
  name   = "node"
  role   = aws_iam_role.node.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"NodeDescribeResources\",\"Effect\":\"Allow\",\"Action\":[\"ec2:DescribeInstanceStatus\",\"ec2:DescribeTags\",\"ec2:DescribeInstances\",\"ec2:DescribeRegions\"],\"Resource\":\"*\"}]}"
}

resource "aws_iam_role_policy" "node_ecr" {
  name   = "ecr"
  role   = aws_iam_role.node.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"ECR\",\"Effect\":\"Allow\",\"Action\":[\"ecr:GetAuthorizationToken\",\"ecr:BatchCheckLayerAvailability\",\"ecr:GetDownloadUrlForLayer\",\"ecr:GetRepositoryPolicy\",\"ecr:DescribeRepositories\",\"ecr:ListImages\",\"ecr:BatchGetImage\"],\"Resource\":\"*\"}]}"
}

resource "aws_iam_role_policy" "node_cni" {
  name   = "cni"
  role   = aws_iam_role.node.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"NodeAwsVpcCNI\",\"Effect\":\"Allow\",\"Action\":[\"ec2:CreateNetworkInterface\",\"ec2:AttachNetworkInterface\",\"ec2:DeleteNetworkInterface\",\"ec2:DetachNetworkInterface\",\"ec2:DescribeNetworkInterfaces\",\"ec2:DescribeInstances\",\"ec2:ModifyNetworkInterfaceAttribute\",\"ec2:AssignPrivateIpAddresses\",\"tag:TagResources\"],\"Resource\":\"*\"}]}"
}

resource "aws_iam_role_policy" "node_assume" {
  name   = "assume"
  role   = aws_iam_role.node.id
  policy = "{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Action\": [\"sts:AssumeRole\"],\"Resource\": \"*\"}]}"
}