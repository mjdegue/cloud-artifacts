# TODO: output the bucket's name (id) and ARN.
# You'll paste the ARN into the boto3 script (Build 3) and the IAM exercise (Build 4).
output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}