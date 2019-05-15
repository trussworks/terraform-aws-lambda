<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Creates a lambda function with associated role and policies, which
will log to Cloudwatch Logs.

Creates the following resources:

* Lambda function
* IAM role and policies described in the inputs
* Cloudwatch Logs group

## Usage

```hcl
module "my_lambda_function" {
  source                = "trussworks/terraform-aws-lambda"
  name                  = "my_app"
  job_identifier        = "instance_alpha"
  runtime               = "go1.x"
  role_policy_arns      = ["${aws_iam_policy.my_app_lambda_policy.arn}"]
  s3_bucket             = "my_s3_bucket"
  s3_key                = "my_app/1.0/my_app.zip"

  subnet_ids            = ["subnet-0123456789abcdef0"]
  security_group_ids    = ["sg-0123456789abcdef0"]

  source_types          = ["events"]
  source_arns           = ["${aws_cloudwatch_event_rule.trigger.arn}"]

  env_vars {
    VARNAME = "value"
  }

  tags {
    "Service" = "big_app"
  }

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cloudwatch\_logs\_retention\_days | Number of days to retain logs in Cloudwatch Logs | string | `"30"` | no |
| env\_vars | Map of environment variables for Lambda function | map | `<map>` | no |
| job\_identifier | Identifier for specific instance of Lambda function | string | n/a | yes |
| memory\_size | Size in MB of Lambda function memory allocation | string | `"128"` | no |
| name | Lambda function name | string | n/a | yes |
| role\_policy\_arns | List of policy ARNs to attach to Lambda role | list | n/a | yes |
| runtime | Lambda runtime type | string | n/a | yes |
| s3\_bucket | Name of s3 bucket used for Lambda build | string | n/a | yes |
| s3\_key | Key for s3 object for Lambda function code | string | n/a | yes |
| security\_group\_ids | List of security group IDs for Lambda VPC config (leave empty if no VPC) | list | `<list>` | no |
| source\_arns | List of arns for Lambda triggers; order must match source_types | list | `<list>` | no |
| source\_types | List of sources for Lambda triggers; order must match source_arns | list | `<list>` | no |
| subnet\_ids | List of subnet IDs for Lambda VPC config (leave empty if no VPC) | list | `<list>` | no |
| tags | Map of tags for Lambda function | map | `<map>` | no |
| timeout | Timeout in seconds for Lambda function timeout | string | `"60"` | no |

## Outputs

| Name | Description |
|------|-------------|
| function\_name | Name of the AWS Lambda function |
| invoke\_arn | ARN used to invoke Lambda function from API Gateway |
| lambda\_arn | ARN for the Lambda function |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
