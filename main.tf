/**
 * Creates a lambda function with associated role and policies, which
 * will log to Cloudwatch Logs.
 *
 * Creates the following resources:
 *
 * * Lambda function
 * * IAM role with policy to allow logging to Cloudwatch Logs
 * * Cloudwatch Logs group
 *
 * ## Usage
 *
 * ```hcl
 * module "my_lambda_function" {
 *   source                 = "trussworks/lambda/aws"
 *   name                   = "my_app"
 *   job_identifier         = "instance_alpha"
 *   runtime                = "go1.x"
 *   role_policy_arns_count = 1
 *   role_policy_arns       = ["${aws_iam_policy.my_app_lambda_policy.arn}"]
 *   s3_bucket              = "my_s3_bucket"
 *   s3_key                 = "my_app/1.0/my_app.zip"
 *
 *   subnet_ids             = ["subnet-0123456789abcdef0"]
 *   security_group_ids     = ["sg-0123456789abcdef0"]
 *
 *   source_types           = ["events"]
 *   source_arns            = ["${aws_cloudwatch_event_rule.trigger.arn}"]
 *
 *   env_vars = {
 *     VARNAME = "value"
 *   }
 *
 *   tags = {
 *     "Service" = "big_app"
 *   }
 *
 * }
 * ```
 */

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  full_name = "${var.name}-${var.job_identifier}"

  # Only use github if project is defined... otherwise default to expecting s3
  from_github   = var.github_project ? 1 : 0
  github_dl_url = "https://github.com/${var.github_project}/releases/download/${var.github_release}"
}

# This is the IAM policy for letting lambda assume roles.
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Define default policy document for writing to Cloudwatch Logs.
data "aws_iam_policy_document" "logs_policy_doc" {
  statement {
    sid    = "WriteCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.full_name}:*"]
  }
}

# Create the IAM role for the Lambda instance.
resource "aws_iam_role" "main" {
  name               = "lambda-${local.full_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach the logging policy to the above IAM role.
resource "aws_iam_role_policy" "main" {
  name = "lambda-${local.full_name}"
  role = aws_iam_role.main.id

  policy = data.aws_iam_policy_document.logs_policy_doc.json
}

# This code verifies that the count of policy ARNs matches the actual
# length of the policy ARNs list. This is a workaround for a Terraform
# limitation.
resource "null_resource" "verify_policy_list_count" {
  provisioner "local-exec" {
    command = <<SH
if [ ${var.role_policy_arns_count} -ne ${length(var.role_policy_arns)} ]; then
  echo "var.role_policy_arns_count must match the actual length of var.role_policy_arns";
  exit 1;
fi
SH
  }

  # Rerun this script if the input values change.
  triggers = {
    role_policy_arns_count_computed = "${length(var.role_policy_arns)}"
    role_policy_arns_count_provided = var.role_policy_arns_count
  }
}

# Attach user-provided policies to role defined above.
resource "aws_iam_role_policy_attachment" "user_policy_attach" {
  count      = var.role_policy_arns_count
  role       = aws_iam_role.main.name
  policy_arn = var.role_policy_arns[count.index]
}

# Cloudwatch Logs
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${local.full_name}"
  retention_in_days = var.cloudwatch_logs_retention_days

  tags = {
    Name = local.full_name
  }
}

# Lambda function from s3
resource "aws_lambda_function" "main_from_s3" {
  count      = local.from_github ? 0 : 1
  depends_on = [aws_cloudwatch_log_group.main]

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  function_name = local.full_name
  role          = aws_iam_role.main.arn
  handler       = var.name
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout

  environment {
    variables = var.env_vars
  }

  tags = var.tags

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}


# Only on Lambda function from github
resource "null_resource" "get_github_release_artifact" {
  count = local.from_github ? 1 : 0
  triggers = {
    version_string = "${var.github_release}"
    file_hash      = "${var.validation_sha}"
  }
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/dl-release.sh ${local.github_dl_url} ${var.github_filename} ${var.validation_sha}"
  }
}

# Only on Lambda function from github
resource "aws_lambda_function" "main_from_gh" {
  count      = local.from_github ? 1 : 0
  depends_on = [aws_cloudwatch_log_group.main]

  filename         = var.github_filename
  source_code_hash = var.validation_sha

  function_name = local.full_name
  role          = aws_iam_role.main.arn
  handler       = var.name
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout

  environment {
    variables = var.env_vars
  }

  tags = var.tags

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

# Add lambda permissions for acting on various triggers.
resource "aws_lambda_permission" "allow_source" {
  count = "${length(var.source_types)}"

  statement_id = "AllowExecutionForLambda-${var.source_types[count.index]}"

  action        = "lambda:InvokeFunction"
  function_name = local.full_name

  principal  = "${var.source_types[count.index]}.amazonaws.com"
  source_arn = "${var.source_arns[count.index]}"
}
