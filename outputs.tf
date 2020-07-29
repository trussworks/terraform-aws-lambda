output "function_name" {
  description = "Name of the AWS Lambda function"
  value       = "${aws_lambda_function.main_from_gh ? aws_lambda_function.main_from_gh.function_name : aws_lambda_function.main_from_s3.function_name}"
}

output "lambda_arn" {
  description = "ARN for the Lambda function"
  value       = "${aws_lambda_function.main_from_gh ? aws_lambda_function.main_from_gh.arn : aws_lambda_function.main_from_s3.arn}"
}

output "invoke_arn" {
  description = "ARN used to invoke Lambda function from API Gateway"
  value       = "${aws_lambda_function.main_from_gh ? aws_lambda_function.main_from_gh.invoke_arn : aws_lambda_function.main_from_s3.invoke_arn}"
}
