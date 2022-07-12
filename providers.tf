terraform {
  required_version = ">= 1.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.15.1"
    }
  }
}

provider "aws" {
  access_key                  = var.aws_access_key
  profile                     = var.aws_profile
  region                      = var.aws_region
  secret_key                  = var.aws_secret_key
  skip_credentials_validation = var.aws_skip_credential_validation
  skip_metadata_api_check     = var.aws_skip_metadata_api_check
  skip_requesting_account_id  = var.aws_skip_requesting_account_id

  default_tags {
    tags = var.tags
  }

  endpoints {
    cloudtrail = var.aws_cloudtrail_endpoint
    cloudwatch = var.aws_cloudwatch_endpoint
    iam        = var.aws_iam_endpoint
    logs       = var.aws_logs_endpoint
    s3         = var.aws_s3_endpoint
  }
}
