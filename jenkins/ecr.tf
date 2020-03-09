# ----------------------------------------------------------------------------#
# Create a Elastic Container Repository to store the docker images            #
# ----------------------------------------------------------------------------#

resource "aws_ecr_repository" "repositories" {
  for_each = toset([
    "aws-devops-fibonacci",
    "aws-devops-kubernetes-api",
    "aws-devops-web-ui"])
  
  name = each.key

  tags = merge(local.common_tags, map(
    "Name", each.key
  ))
}