# ----------------------------------------------------------------------------#
# Get the AMI for the Jenkins server                                          #
# ----------------------------------------------------------------------------#

data "aws_ami" "server_image" {
  most_recent = true
  owners = ["161831738826"]

  filter {
    name   = "name"
    values = ["centos-7-base-*"]
  }
}

# ----------------------------------------------------------------------------#
# Create the Jenkins server in the private Jenkins subnet                     #
# ----------------------------------------------------------------------------#

resource "aws_instance" "jenkins" {
  depends_on             = [aws_ecr_repository.repositories]
  subnet_id              = aws_subnet.private_jenkins.id
  ami                    = data.aws_ami.server_image.id
  instance_type          = var.server_instance_type
  key_name               = data.terraform_remote_state.vpc.outputs.key_name
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name
  user_data              = join("\n", [
                           "#!/bin/bash",
                           "ACCOUNT_ID=${var.account_id}",
                           "REGION_NAME=${var.region_name}",
                           "PROJECT_NAME=${var.project_name}",
                           "BUCKET_NAME=${var.bucket_name}",
                           "ECR_URL=${split("/", aws_ecr_repository.repositories["aws-devops-web-ui"].repository_url)[0]}",
                           file("${path.module}/scripts/setup-jenkins.sh")])

  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-private-jenkins"
  ))
}

# ----------------------------------------------------------------------------#
# Create the firewall rules for the NAT gateway                               #
# ----------------------------------------------------------------------------#

resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-private-jenkins"
  description = "Allows access to the Jenkins server."
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Ingress Rules

  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress Rules

  egress {
    description = "All access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, map(
    "Name", "${var.project_name}-private-jenkins"
  ))
}