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
  subnet_id              = aws_subnet.private_jenkins.id
  ami                    = data.aws_ami.server_image.id
  instance_type          = var.server_instance_type
  key_name               = data.terraform_remote_state.vpc.outputs.key_name
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  user_data              = join("\n", [
                           "#!/bin/bash",
                           "PROJECT_NAME=${var.project_name}",
                           "PASSWORD_HASH=${data.external.hash_password.result.hash}",
                           file("scripts/setup-jenkins.sh")])

  tags = merge(local.common_tags, map(
    "Name", "jenkins"
  ))
}

# ----------------------------------------------------------------------------#
# Declare an external shell script that can hash a password                   #
# ----------------------------------------------------------------------------#

data "external" "hash_password" {
  program = ["bash", "-c", "${path.root}/scripts/hash-password.sh ${var.jenkins_admin_password}"]
}

# ----------------------------------------------------------------------------#
# Create the firewall rules for the NAT gateway                               #
# ----------------------------------------------------------------------------#

resource "aws_security_group" "jenkins" {
  name        = "jenkins"
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, map(
    "Name", "jenkins"
  ))
}