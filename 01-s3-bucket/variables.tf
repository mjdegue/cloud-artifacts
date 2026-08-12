# TODO: declare var.bucket_name
# - type string
# - no default (forces you to pass it: terraform apply -var 'bucket_name=...')
# - bonus: a validation block enforcing S3 naming rules (lowercase, 3-63 chars)

variable "bucket_name" {
  type        = string
  description = "Name for the bucket in use"

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63 && can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name should be in between 3 and 63 characters long."
  }
}