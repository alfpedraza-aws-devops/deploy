# ----------------------------------------------------------------------------#
# Required Parameters                                                         #
# ----------------------------------------------------------------------------#

variable "region_name" {
  description = "The name of the region where the resources will be created"
  type = string
}

variable "bucket_name" {
  description = "The name of the AWS S3 bucket where the state will be stored"
  type = string
}

variable "table_name" {
  description = "The name of the AWS DynamoDB table where the lock will be stored"
  type = string
}