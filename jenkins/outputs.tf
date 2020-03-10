# ----------------------------------------------------------------------------#
# Output values                                                               #
# ----------------------------------------------------------------------------#

output "jenkins_security_group_id" {
  value       = aws_security_group.jenkins.id
  description = "The id of the Jenkins Security Group"
}