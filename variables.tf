variable "aws_access_key" {
  type        = string
  default     = null
  description = "The AWS access key that grants programmatic access to your resources."

  validation {
    condition = (var.aws_access_key == null) || var.aws_access_key == "test"

    error_message = "The aws_access_key variable must have a value of \"test\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "aws_cloudtrail_endpoint" {
  type        = string
  default     = null
  description = "A custom endpoint for the AWS CloudTrail service."

  validation {
    condition = (var.aws_cloudtrail_endpoint == null) || var.aws_cloudtrail_endpoint == "http://localhost:4566"

    error_message = "The aws_cloudtrail_endpoint variable must have a value of \"http://localhost:4566\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "aws_cloudwatch_endpoint" {
  type        = string
  default     = null
  description = "A custom endpoint for the AWS CloudWatch service."

  validation {
    condition = (var.aws_cloudwatch_endpoint == null) || var.aws_cloudwatch_endpoint == "http://localhost:4566"

    error_message = "The aws_cloudwatch_endpoint variable must have a value of \"http://localhost:4566\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "aws_iam_endpoint" {
  type        = string
  default     = null
  description = "A custom endpoint for the AWS IAM service."

  validation {
    condition = (var.aws_iam_endpoint == null) || var.aws_iam_endpoint == "http://localhost:4566"

    error_message = "The aws_iam_endpoint variable must have a value of \"http://localhost:4566\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "aws_logs_endpoint" {
  type        = string
  default     = null
  description = "A custom endpoint for the AWS logs service."

  validation {
    condition = (var.aws_logs_endpoint == null) || var.aws_logs_endpoint == "http://localhost:4566"

    error_message = "The aws_logs_endpoint variable must have a value of \"http://localhost:4566\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "aws_s3_endpoint" {
  type        = string
  default     = null
  description = "A custom endpoint for the AWS s3 service."

  validation {
    condition = (var.aws_s3_endpoint == null) || var.aws_s3_endpoint == "http://localhost:4566"

    error_message = "The aws_s3_endpoint variable must have a value of \"http://localhost:4566\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "The named AWS profile that will be used from an external source."
}

variable "aws_secret_key" {
  type        = string
  default     = null
  description = "The AWS secret key that grants programmatic access to your resources."

  validation {
    condition = (var.aws_secret_key == null) || var.aws_secret_key == "test"

    error_message = "The aws_secret_key variable must have a value of \"test\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "aws_skip_credential_validation" {
  type        = bool
  default     = null
  description = "Whether to skip credentials validation via the AWS STS API."

  validation {
    condition = (var.aws_skip_credential_validation == null) || var.aws_skip_credential_validation == true

    error_message = "The aws_skip_credential_validation variable must have a value of \"true\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "The default AWS region that Terraform will target."

  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
    error_message = "The aws_region variable must be valid AWS Region name."
  }
}

variable "aws_skip_metadata_api_check" {
  type        = bool
  default     = null
  description = "Whether or not Terraform should authenticate via the AWS Metadata API."

  validation {
    condition = (var.aws_skip_metadata_api_check == null) || var.aws_skip_metadata_api_check == true

    error_message = "The aws_skip_metadata_api_check variable must have a value of \"true\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "aws_skip_requesting_account_id" {
  type        = bool
  default     = null
  description = "Whether or not the requesting aws account id will be determined by the Terraform AWS provider."

  validation {
    condition = (var.aws_skip_requesting_account_id == null) || var.aws_skip_requesting_account_id == true

    error_message = "The aws_skip_requesting_account_idvariable must have a value of \"true\", or the variable must not be defined at all in the .tfvars file."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags that will be applied to all Terraform created resources that can be tagged."
}
