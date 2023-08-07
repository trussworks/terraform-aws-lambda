variable "name" {
  description = "Lambda function name"
  type        = string
}

variable "job_identifier" {
  description = "Identifier for specific instance of Lambda function"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime type"
  type        = string
}

# Either deploy from a specified bucket
variable "s3_bucket" {
  description = "Name of s3 bucket used for Lambda build"
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "Key for s3 object for Lambda function code"
  type        = string
  default     = ""
}

# Or deploy from a specified Github repo/version
variable "github_project" {
  default     = ""
  type        = string
  description = "The unique Github project to pull from. Currently, this must be public. Eg. 'trussworks/aws-iam-sleuth'"
}

variable "github_release" {
  default     = ""
  type        = string
  description = "The release tag to download."
}

variable "github_filename" {
  default     = "deployment.zip"
  type        = string
  description = "Name of the file to get when building url to pull."
}

variable "validation_sha" {
  default     = ""
  type        = string
  description = "SHA to validate the file."
}

# We need an explicit count because of Terraform issue 17421
variable "role_policy_arns_count" {
  description = "Count of policy ARNs to attach to Lambda role"
  type        = string
}

variable "role_policy_arns" {
  description = "List of policy ARNs to attach to Lambda role"
  type        = list(any)
}


variable "memory_size" {
  default     = 128
  description = "Size in MB of Lambda function memory allocation"
  type        = string
}

variable "ephemeral_storage" {
  default     = 512
  description = "Size in MB of Lambda function ephemeral storage allocation"
  type        = string
}

variable "timeout" {
  default     = 60
  description = "Timeout in seconds for Lambda function timeout"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Map of tags for Lambda function"
  type        = map(any)
}

variable "env_vars" {
  default     = {}
  description = "Map of environment variables for Lambda function"
  type        = map(any)
}

variable "subnet_ids" {
  default     = []
  description = "List of subnet IDs for Lambda VPC config (leave empty if no VPC)"
  type        = list(any)
}

variable "security_group_ids" {
  default     = []
  description = "List of security group IDs for Lambda VPC config (leave empty if no VPC)"
  type        = list(any)
}

variable "cloudwatch_logs_retention_days" {
  default     = 30
  description = "Number of days to retain logs in Cloudwatch Logs"
  type        = string
}

variable "source_types" {
  default     = []
  description = "List of sources for Lambda triggers; order must match source_arns"
  type        = list(any)
}

variable "source_arns" {
  default     = []
  description = "List of arns for Lambda triggers; order must match source_types"
  type        = list(any)
}

variable "handler" {
  default     = "main.Main"
  description = "The entrypoint function for the lambda function."
  type        = string
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version."
  type        = bool
  default     = false
}

variable "cloudwatch_encryption_key_arn" {
  description = "The arn of the encryption key to be used for the cloudwatch logs"
  type        = string
  default     = ""
}

variable "iam_policy_conditions" {
  description = "conditions to attach to the assume role trust policy"
  type = list(
    object({
      test     = string
      variable = string
      values   = list(string)
    })
  )
  default = [{
    test     = "StringEquals"
    variable = "aws:SourceAccount"
    values   = [data.aws_caller_identity.current.account_id]
  }]
}
