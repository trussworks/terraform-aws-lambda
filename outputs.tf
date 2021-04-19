output "function_name" {
  description = "Name of the AWS Lambda function"
  value       = length(aws_lambda_function.main_from_gh) == 1 ? aws_lambda_function.main_from_gh[0].function_name : aws_lambda_function.main_from_s3[0].function_name
}

output "lambda_arn" {
  description = "ARN for the Lambda function"
  value       = length(aws_lambda_function.main_from_gh) == 1 ? aws_lambda_function.main_from_gh[0].arn : aws_lambda_function.main_from_s3[0].arn
}

output "invoke_arn" {
  description = "ARN used to invoke Lambda function from API Gateway"
  value       = length(aws_lambda_function.main_from_gh) == 1 ? aws_lambda_function.main_from_gh[0].invoke_arn : aws_lambda_function.main_from_s3[0].invoke_arn
}
