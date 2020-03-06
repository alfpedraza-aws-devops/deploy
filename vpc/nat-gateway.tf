# ----------------------------------------------------------------------------#
# Get the AMI for the NAT gateway                                             #
# ----------------------------------------------------------------------------#

data "aws_ami" "nat_instance" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-hvm-*-x86_64-ebs"]
  }
}

# ----------------------------------------------------------------------------#
# Create the NAT gateway in the public subnet                                 #
# ----------------------------------------------------------------------------#

resource "aws_instance" "nat_gateway" {
  subnet_id              = aws_subnet.public.id
  ami                    = data.aws_ami.nat_instance.id
  instance_type          = var.nat_gateway_instance_type
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.nat_gateway.id]
  source_dest_check      = false

  tags = merge(local.common_tags, map(
    "Name", "nat-gateway"
  ))
}

# ----------------------------------------------------------------------------#
# Create the firewall rules for the NAT gateway                               #
# ----------------------------------------------------------------------------#

resource "aws_security_group" "nat_gateway" {
  name        = "nat-gateway"
  description = "Allows access to the NAT Gateway."
  vpc_id      = aws_vpc.vpc.id

  # Ingress Rules

  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.private_jenkins_subnet_cidr_block,
                   var.private_dev_subnet_cidr_block,
                   var.private_prod_subnet_cidr_block]
  }

  ingress {
    description = "HTTPS Port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.private_jenkins_subnet_cidr_block,
                   var.private_dev_subnet_cidr_block,
                   var.private_prod_subnet_cidr_block]
  }

  ingress {
    description = "Kubernetes API Server Port"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress Rules

  egress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP Port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS Port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Kubernetes API Server Port"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, map(
    "Name", "nat-gateway"
  ))
}