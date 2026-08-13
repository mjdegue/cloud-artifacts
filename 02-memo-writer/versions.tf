terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      project    = "cloud-artifacts"
      artifact   = "02-memo-writer"
      managed-by = "terraform"
    }
  }
}
