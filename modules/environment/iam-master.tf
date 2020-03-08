# ----------------------------------------------------------------------------#
# Create instance profile that the master node server will hold               #
# ----------------------------------------------------------------------------#

resource "aws_iam_instance_profile" "master" {
  name = "${var.project_name}-${var.region_name}-${var.environment_name}-master"
  role = aws_iam_role.master.name
}

# ----------------------------------------------------------------------------#
# Create the IAM role for the master node server                              #
# ----------------------------------------------------------------------------#

resource "aws_iam_role" "master" {
  name               = "${var.project_name}-${var.region_name}-${var.environment_name}-master"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
}

# ----------------------------------------------------------------------------#
# Define several policies that will be attached to the master role            #
# ----------------------------------------------------------------------------#

resource "aws_iam_role_policy" "master_instance" {
  name   = "master"
  role   = aws_iam_role.master.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"MasterDescribeResources\",\"Effect\":\"Allow\",\"Action\":[\"ec2:DescribeInstances\",\"ec2:DescribeRegions\",\"ec2:DescribeRouteTables\",\"ec2:DescribeSecurityGroups\",\"ec2:DescribeSubnets\",\"ec2:DescribeVolumes\",\"s3:CreateBucket\",\"s3:PutObject\"],\"Resource\":\"*\"},{\"Sid\":\"MasterAllResourcesWriteable\",\"Effect\":\"Allow\",\"Action\":[\"ec2:CreateRoute\",\"ec2:CreateSecurityGroup\",\"ec2:CreateTags\",\"ec2:CreateVolume\",\"ec2:ModifyInstanceAttribute\"],\"Resource\":\"*\"},{\"Sid\":\"MasterTaggedResourcesWritable\",\"Effect\":\"Allow\",\"Action\":[\"ec2:AttachVolume\",\"ec2:AuthorizeSecurityGroupIngress\",\"ec2:DeleteRoute\",\"ec2:DeleteSecurityGroup\",\"ec2:DeleteVolume\",\"ec2:DetachVolume\",\"ec2:RevokeSecurityGroupIngress\"],\"Resource\":\"*\"}]}"
}

resource "aws_iam_role_policy" "master_ecr" {
  name   = "ecr"
  role   = aws_iam_role.master.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"ECR\",\"Effect\":\"Allow\",\"Action\":[\"ecr:GetAuthorizationToken\",\"ecr:BatchCheckLayerAvailability\",\"ecr:GetDownloadUrlForLayer\",\"ecr:GetRepositoryPolicy\",\"ecr:DescribeRepositories\",\"ecr:ListImages\",\"ecr:BatchGetImage\"],\"Resource\":\"*\"}]}"
}

resource "aws_iam_role_policy" "master_cni" {
  name   = "cni"
  role   = aws_iam_role.master.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"NodeAwsVpcCNI\",\"Effect\":\"Allow\",\"Action\":[\"ec2:CreateNetworkInterface\",\"ec2:AttachNetworkInterface\",\"ec2:DeleteNetworkInterface\",\"ec2:DetachNetworkInterface\",\"ec2:DescribeNetworkInterfaces\",\"ec2:DescribeInstances\",\"ec2:ModifyNetworkInterfaceAttribute\",\"ec2:AssignPrivateIpAddresses\",\"tag:TagResources\"],\"Resource\":\"*\"}]}"
}

resource "aws_iam_role_policy" "master_autoscaler" {
  name   = "autoscaler"
  role   = aws_iam_role.master.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"ClusterAutoscalerDescribe\",\"Effect\":\"Allow\",\"Action\":[\"autoscaling:DescribeAutoScalingGroups\",\"autoscaling:DescribeAutoScalingInstances\",\"autoscaling:DescribeTags\",\"autoscaling:DescribeLaunchConfigurations\"],\"Resource\":\"*\"},{\"Sid\":\"ClusterAutoscalerTaggedResourcesWritable\",\"Effect\":\"Allow\",\"Action\":[\"autoscaling:SetDesiredCapacity\",\"autoscaling:TerminateInstanceInAutoScalingGroup\",\"autoscaling:UpdateAutoScalingGroup\"],\"Resource\":\"*\"}]}"
}

resource "aws_iam_role_policy" "master_loadbalancing" {
  name   = "loadbalancing"
  role   = aws_iam_role.master.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"ELB\",\"Effect\":\"Allow\",\"Action\":[\"elasticloadbalancing:AddTags\",\"elasticloadbalancing:AttachLoadBalancerToSubnets\",\"elasticloadbalancing:ApplySecurityGroupsToLoadBalancer\",\"elasticloadbalancing:CreateLoadBalancer\",\"elasticloadbalancing:CreateLoadBalancerPolicy\",\"elasticloadbalancing:CreateLoadBalancerListeners\",\"elasticloadbalancing:ConfigureHealthCheck\",\"elasticloadbalancing:DeleteLoadBalancer\",\"elasticloadbalancing:DeleteLoadBalancerListeners\",\"elasticloadbalancing:DescribeLoadBalancers\",\"elasticloadbalancing:DescribeLoadBalancerAttributes\",\"elasticloadbalancing:DetachLoadBalancerFromSubnets\",\"elasticloadbalancing:DeregisterInstancesFromLoadBalancer\",\"elasticloadbalancing:ModifyLoadBalancerAttributes\",\"elasticloadbalancing:RegisterInstancesWithLoadBalancer\",\"elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer\"],\"Resource\":\"*\"},{\"Sid\":\"NLB\",\"Effect\":\"Allow\",\"Action\":[\"ec2:DescribeVpcs\",\"elasticloadbalancing:AddTags\",\"elasticloadbalancing:CreateListener\",\"elasticloadbalancing:CreateTargetGroup\",\"elasticloadbalancing:DeleteListener\",\"elasticloadbalancing:DeleteTargetGroup\",\"elasticloadbalancing:DescribeListeners\",\"elasticloadbalancing:DescribeLoadBalancerPolicies\",\"elasticloadbalancing:DescribeTargetGroups\",\"elasticloadbalancing:DescribeTargetHealth\",\"elasticloadbalancing:ModifyListener\",\"elasticloadbalancing:ModifyTargetGroup\",\"elasticloadbalancing:RegisterTargets\",\"elasticloadbalancing:SetLoadBalancerPoliciesOfListener\"],\"Resource\":\"*\"}]}"
}

resource "aws_iam_role_policy" "master_assume" {
  name   = "assume"
  role   = aws_iam_role.master.id
  policy = "{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Action\": [\"sts:AssumeRole\"],\"Resource\": \"*\"}]}"
}