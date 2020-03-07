# ----------------------------------------------------------------------------#
# Create a Elastic Container Repository to store the docker images            #
# ----------------------------------------------------------------------------#

resource "aws_ecr_repository" "repository" {
  name = var.project_name

  tags = merge(local.common_tags, map(
    "Name", var.project_name
  ))
}