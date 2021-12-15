Creates a lambda function with associated role and policies, which
will log to Cloudwatch Logs.

Creates the following resources:

* Lambda function
* IAM role with policy to allow logging to Cloudwatch Logs
* Cloudwatch Logs group

## Usage

```hcl
module "my_lambda_function" {
  source                 = "trussworks/lambda/aws"
  name                   = "my_app"
  job_identifier         = "instance_alpha"
  runtime                = "go1.x"
  role_policy_arns_count = 1
  role_policy_arns       = [aws_iam_policy.my_app_lambda_policy.arn]
  s3_bucket              = "my_s3_bucket"
  s3_key                 = "my_app/1.0/my_app.zip"

  subnet_ids             = ["subnet-0123456789abcdef0"]
  security_group_ids     = ["sg-0123456789abcdef0"]

  source_types           = ["events"]
  source_arns            = [aws_cloudwatch_event_rule.trigger.arn]

  env_vars = {
    VARNAME = "value"
  }

  tags = {
    "Service" = "big_app"
  }

}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.69.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.user_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.main_from_gh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.main_from_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_source_gh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_source_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [null_resource.get_github_release_artifact](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.verify_policy_list_count](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_encryption_key_arn"></a> [cloudwatch\_encryption\_key\_arn](#input\_cloudwatch\_encryption\_key\_arn) | The arn of the encryption key to be used for the cloudwatch logs | `string` | `""` | no |
| <a name="input_cloudwatch_logs_retention_days"></a> [cloudwatch\_logs\_retention\_days](#input\_cloudwatch\_logs\_retention\_days) | Number of days to retain logs in Cloudwatch Logs | `string` | `30` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Map of environment variables for Lambda function | `map(any)` | `{}` | no |
| <a name="input_github_filename"></a> [github\_filename](#input\_github\_filename) | Name of the file to get when building url to pull. | `string` | `"deployment.zip"` | no |
| <a name="input_github_project"></a> [github\_project](#input\_github\_project) | The unique Github project to pull from. Currently, this must be public. Eg. 'trussworks/aws-iam-sleuth' | `string` | `""` | no |
| <a name="input_github_release"></a> [github\_release](#input\_github\_release) | The release tag to download. | `string` | `""` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | The entrypoint function for the lambda function. | `string` | `"main.Main"` | no |
| <a name="input_job_identifier"></a> [job\_identifier](#input\_job\_identifier) | Identifier for specific instance of Lambda function | `string` | n/a | yes |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Size in MB of Lambda function memory allocation | `string` | `128` | no |
| <a name="input_name"></a> [name](#input\_name) | Lambda function name | `string` | n/a | yes |
| <a name="input_publish"></a> [publish](#input\_publish) | Whether to publish creation/change as new Lambda Function Version. | `bool` | `false` | no |
| <a name="input_role_policy_arns"></a> [role\_policy\_arns](#input\_role\_policy\_arns) | List of policy ARNs to attach to Lambda role | `list(any)` | n/a | yes |
| <a name="input_role_policy_arns_count"></a> [role\_policy\_arns\_count](#input\_role\_policy\_arns\_count) | Count of policy ARNs to attach to Lambda role | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Lambda runtime type | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | Name of s3 bucket used for Lambda build | `string` | `""` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | Key for s3 object for Lambda function code | `string` | `""` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs for Lambda VPC config (leave empty if no VPC) | `list(any)` | `[]` | no |
| <a name="input_source_arns"></a> [source\_arns](#input\_source\_arns) | List of arns for Lambda triggers; order must match source\_types | `list(any)` | `[]` | no |
| <a name="input_source_types"></a> [source\_types](#input\_source\_types) | List of sources for Lambda triggers; order must match source\_arns | `list(any)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for Lambda VPC config (leave empty if no VPC) | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags for Lambda function | `map(any)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout in seconds for Lambda function timeout | `string` | `60` | no |
| <a name="input_validation_sha"></a> [validation\_sha](#input\_validation\_sha) | SHA to validate the file. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the AWS Lambda function |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | ARN used to invoke Lambda function from API Gateway |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | ARN for the Lambda function |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Terraform Versions

Terraform 0.13 and later. Pin module version to ~> 2.0. Submit pull requests to `master` branch.
