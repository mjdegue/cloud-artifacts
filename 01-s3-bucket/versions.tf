terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  # Region comes from your AWS CLI profile; pin it explicitly if you prefer:
  # region = "us-east-1"

  default_tags {
    tags = {
      project    = "cloud-artifacts"
      artifact   = "01-s3-bucket"
      managed-by = "terraform"
    }
  }
}
