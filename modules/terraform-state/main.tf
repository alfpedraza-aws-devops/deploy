###############################################################################
# This module will create the resources required to store terraform state     #
# files remotely.                                                             #
###############################################################################

# ----------------------------------------------------------------------------#
# Create the AWS S3 bucket where the state will be stored.                    #
# ----------------------------------------------------------------------------#

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
  region = var.region_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ----------------------------------------------------------------------------#
# Create the AWS DynamoDB table where the lock will be stored.                #
# ----------------------------------------------------------------------------#

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}