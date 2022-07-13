# tf_localstack_aws_template
A template repository used to bootstrap Terraform AWS projects

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.15.1 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | The AWS access key that grants programmatic access to your resources. | `string` | `null` | no |
| <a name="input_aws_cloudtrail_endpoint"></a> [aws\_cloudtrail\_endpoint](#input\_aws\_cloudtrail\_endpoint) | A custom endpoint for the AWS CloudTrail service. | `string` | `null` | no |
| <a name="input_aws_cloudwatch_endpoint"></a> [aws\_cloudwatch\_endpoint](#input\_aws\_cloudwatch\_endpoint) | A custom endpoint for the AWS CloudWatch service. | `string` | `null` | no |
| <a name="input_aws_iam_endpoint"></a> [aws\_iam\_endpoint](#input\_aws\_iam\_endpoint) | A custom endpoint for the AWS IAM service. | `string` | `null` | no |
| <a name="input_aws_logs_endpoint"></a> [aws\_logs\_endpoint](#input\_aws\_logs\_endpoint) | A custom endpoint for the AWS logs service. | `string` | `null` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The named AWS profile that will be used from an external source. | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The default AWS region that Terraform will target. | `string` | `"us-west-2"` | no |
| <a name="input_aws_s3_endpoint"></a> [aws\_s3\_endpoint](#input\_aws\_s3\_endpoint) | A custom endpoint for the AWS s3 service. | `string` | `null` | no |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | The AWS secret key that grants programmatic access to your resources. | `string` | `null` | no |
| <a name="input_aws_skip_credential_validation"></a> [aws\_skip\_credential\_validation](#input\_aws\_skip\_credential\_validation) | Whether to skip credentials validation via the AWS STS API. | `bool` | `null` | no |
| <a name="input_aws_skip_metadata_api_check"></a> [aws\_skip\_metadata\_api\_check](#input\_aws\_skip\_metadata\_api\_check) | Whether or not Terraform should authenticate via the AWS Metadata API. | `bool` | `null` | no |
| <a name="input_aws_skip_requesting_account_id"></a> [aws\_skip\_requesting\_account\_id](#input\_aws\_skip\_requesting\_account\_id) | Whether or not the requesting aws account id will be determined by the Terraform AWS provider. | `bool` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that will be applied to all Terraform created resources that can be tagged. | `map(string)` | `{}` | no |

## Outputs

No outputs.

## Usage
Setup development environment and apply Terraform (CI)
```shell
make integration-test-ci
```

Setup local development environment and apply Terraform
```shell
make local-development
```

Destroy development environment
```shell
make clean
```

Add additional AWS services to localstack by adding the service to the [make](https://github.com/ChaosCypher/tf_localstack_aws_template/blob/main/Makefile#L6) variable
