output "function_name" {
  description = "Name of the AWS Lambda function"
  value       = "${aws_lambda_function.main.function_name}"
}

output "lambda_arn" {
  description = "ARN for the Lambda function"
  value       = "${aws_lambda_function.main.arn}"
}

output "invoke_arn" {
  description = "ARN used to invoke Lambda function from API Gateway"
  value       = "${aws_lambda_function.main.invoke_arn}"
}
