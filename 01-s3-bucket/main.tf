# Artifact 01 — S3 bucket: versioned, encrypted, policy-enforced encryption.
#
# Fill in the four resources below. Work with the Terraform AWS provider docs open:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# (search each resource type by name)
#
# Loop: terraform init -> plan -> apply -> inspect in console/CLI -> destroy when done.

# TODO 1: the bucket itself
# Resource type: aws_s3_bucket
# - Bucket names are GLOBAL across all AWS accounts — use var.bucket_name.
# - Nothing else is configured here; versioning/encryption are separate resources (post-2022 provider design).
# resource "aws_s3_bucket" "this" {
# }

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

# TODO 2: versioning
# Resource type: aws_s3_bucket_versioning
# - References the bucket above via its id attribute (aws_s3_bucket.this.id).
# - Status should be "Enabled".
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# TODO 3: server-side encryption
# Resource type: aws_s3_bucket_server_side_encryption_configuration
# - Simplest valid choice: SSE-S3, i.e. sse_algorithm "AES256" (no KMS key needed).
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# TODO 4: bucket policy denying unencrypted uploads
# Resource type: aws_s3_bucket_policy
# - The policy document is IAM-policy JSON: Effect / Principal / Action / Resource / Condition.
# - Goal: DENY s3:PutObject when the request does not include server-side encryption.
#   Hint: condition key "s3:x-amz-server-side-encryption", and think about Null vs StringNotEquals.
# - Write the JSON with jsonencode() rather than a heredoc string.
# - Resource ARN for objects is the bucket arn + "/*" — bucket-level vs object-level ARNs matter here.
