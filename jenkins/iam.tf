resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-jenkins"
  role = aws_iam_role.jenkins.name
}

resource "aws_iam_role" "jenkins" {
  name               = "${var.project_name}-jenkins"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
}

resource "aws_iam_role_policy" "jenkins" {
  name   = "jenkins"
  role   = aws_iam_role.jenkins.id
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"jenkins\",\"Effect\":\"Allow\",\"Action\":[\"s3:GetObject\",\"s3:DeleteBucket\"],\"Resource\":\"*\"}]}"
}