# ----------------------------------------------------------------------------#
# Create instance profile that the Jenkins server will hold                   #
# ----------------------------------------------------------------------------#

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-${var.region_name}-jenkins"
  role = aws_iam_role.jenkins.name
}

# ----------------------------------------------------------------------------#
# Create the IAM role for the Jenkins server                                  #
# ----------------------------------------------------------------------------#

resource "aws_iam_role" "jenkins" {
  name               = "${var.project_name}-${var.region_name}-jenkins"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
}