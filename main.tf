data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  full_name = "${var.name}-${var.job_identifier}"

  # Only use github if project is defined... otherwise default to expecting s3
  from_github   = var.github_project != "" ? true : false
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
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${local.full_name}"]
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

    resources = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.full_name}:*"]
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
    role_policy_arns_count_computed = length(var.role_policy_arns)
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
  # set the key, else empty string
  kms_key_id = var.cloudwatch_encryption_key_arn
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
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  publish       = var.publish

  environment {
    variables = var.env_vars
  }

  ephemeral_storage {
    size = var.ephemeral_storage
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
    version_string = var.github_release
    file_hash      = var.validation_sha
  }
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/dl-release.sh ${local.github_dl_url} ${var.github_filename} ${var.validation_sha}"
  }
}

# Only on Lambda function from github
resource "aws_lambda_function" "main_from_gh" {
  count = local.from_github ? 1 : 0
  depends_on = [aws_cloudwatch_log_group.main,
  null_resource.get_github_release_artifact]

  filename         = var.github_filename
  source_code_hash = var.validation_sha

  function_name = local.full_name
  role          = aws_iam_role.main.arn
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout

  environment {
    variables = var.env_vars
  }

  ephemeral_storage {
    size = var.ephemeral_storage
  }

  tags = var.tags

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

# Add lambda permissions for acting on various triggers for GH based lambdas.
resource "aws_lambda_permission" "allow_source_gh" {
  count = local.from_github ? length(var.source_types) : 0

  statement_id = "AllowExecutionForLambda-${var.source_types[count.index]}"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_from_gh[0].function_name

  principal  = "${var.source_types[count.index]}.amazonaws.com"
  source_arn = var.source_arns[count.index]
}

# Add lambda permissions for acting on various triggers for S3 based lambdas.
resource "aws_lambda_permission" "allow_source_s3" {
  count = local.from_github ? 0 : length(var.source_types)

  statement_id = "AllowExecutionForLambda-${var.source_types[count.index]}"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_from_s3[0].function_name

  principal  = "${var.source_types[count.index]}.amazonaws.com"
  source_arn = var.source_arns[count.index]
}
