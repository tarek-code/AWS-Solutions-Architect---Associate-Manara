output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.todo_api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${var.environment}"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.todo_table.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.todo_table.arn
}

output "frontend_website_url" {
  description = "URL of the frontend website"
  value       = "http://${aws_s3_bucket_website_configuration.frontend_bucket.website_endpoint}"
}

output "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend"
  value       = aws_s3_bucket.frontend_bucket.bucket
}

output "lambda_functions" {
  description = "Names of the Lambda functions"
  value = {
    create = aws_lambda_function.create_todo.function_name
    read   = aws_lambda_function.read_todo.function_name
    update = aws_lambda_function.update_todo.function_name
    delete = aws_lambda_function.delete_todo.function_name
    list   = aws_lambda_function.list_todos.function_name
  }
}

output "api_endpoints" {
  description = "Available API endpoints"
  value = {
    list_todos  = "GET ${aws_api_gateway_rest_api.todo_api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${var.environment}/todos"
    create_todo = "POST ${aws_api_gateway_rest_api.todo_api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${var.environment}/todos"
    get_todo    = "GET ${aws_api_gateway_rest_api.todo_api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${var.environment}/todos/{id}"
    update_todo = "PUT ${aws_api_gateway_rest_api.todo_api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${var.environment}/todos/{id}"
    delete_todo = "DELETE ${aws_api_gateway_rest_api.todo_api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${var.environment}/todos/{id}"
  }
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for Lambda functions"
  value = {
    for key, log_group in aws_cloudwatch_log_group.lambda_logs : key => log_group.name
  }
}
