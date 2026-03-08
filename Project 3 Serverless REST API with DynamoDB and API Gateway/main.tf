# Provider configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# DynamoDB table for to-do items
resource "aws_dynamodb_table" "todo_table" {
  name         = "todo-items-${random_string.suffix.result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "Todo Items Table"
    Environment = var.environment
    Project     = "Serverless REST API"
  }
}

# S3 bucket for frontend hosting
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "todo-app-frontend-${random_string.suffix.result}"

  tags = {
    Name        = "Todo App Frontend"
    Environment = var.environment
    Project     = "Serverless REST API"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend_bucket]
}

# IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "todo-lambda-role-${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "Todo Lambda Role"
    Environment = var.environment
    Project     = "Serverless REST API"
  }
}

# IAM policy for Lambda functions
resource "aws_iam_role_policy" "lambda_policy" {
  name = "todo-lambda-policy-${random_string.suffix.result}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.todo_table.arn
      }
    ]
  })
}

# CloudWatch log groups for Lambda functions
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = toset(["create", "read", "update", "delete", "list"])

  name              = "/aws/lambda/todo-${each.key}-${random_string.suffix.result}"
  retention_in_days = 14

  tags = {
    Name        = "Todo ${title(each.key)} Lambda Logs"
    Environment = var.environment
    Project     = "Serverless REST API"
  }
}

# Lambda function for creating todo items
resource "aws_lambda_function" "create_todo" {
  filename         = "lambda_functions/create_todo.zip"
  function_name    = "todo-create-${random_string.suffix.result}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "create_todo.handler"
  source_code_hash = data.archive_file.create_todo_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 30

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todo_table.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# Lambda function for reading todo items
resource "aws_lambda_function" "read_todo" {
  filename         = "lambda_functions/read_todo.zip"
  function_name    = "todo-read-${random_string.suffix.result}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "read_todo.handler"
  source_code_hash = data.archive_file.read_todo_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 30

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todo_table.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# Lambda function for updating todo items
resource "aws_lambda_function" "update_todo" {
  filename         = "lambda_functions/update_todo.zip"
  function_name    = "todo-update-${random_string.suffix.result}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "update_todo.handler"
  source_code_hash = data.archive_file.update_todo_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 30

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todo_table.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# Lambda function for deleting todo items
resource "aws_lambda_function" "delete_todo" {
  filename         = "lambda_functions/delete_todo.zip"
  function_name    = "todo-delete-${random_string.suffix.result}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "delete_todo.handler"
  source_code_hash = data.archive_file.delete_todo_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 30

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todo_table.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# Lambda function for listing todo items
resource "aws_lambda_function" "list_todos" {
  filename         = "lambda_functions/list_todos.zip"
  function_name    = "todo-list-${random_string.suffix.result}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "list_todos.handler"
  source_code_hash = data.archive_file.list_todos_zip.output_base64sha256
  runtime          = "python3.9"
  timeout          = 30

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todo_table.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# API Gateway
resource "aws_api_gateway_rest_api" "todo_api" {
  name        = "todo-api-${random_string.suffix.result}"
  description = "Serverless REST API for Todo Management"

  endpoint_configuration {
    types = ["REGIONAL"]
  }


  tags = {
    Name        = "Todo API"
    Environment = var.environment
    Project     = "Serverless REST API"
  }
}

# API Gateway CORS configuration
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_rest_api.todo_api.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_rest_api.todo_api.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_rest_api.todo_api.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Gateway resources and methods
resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
  path_part   = "todos"
}

resource "aws_api_gateway_resource" "todo_id" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_resource.todos.id
  path_part   = "{id}"
}

# GET /todos - List all todos
resource "aws_api_gateway_method" "list_todos" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "list_todos" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.list_todos.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_todos.invoke_arn
}

# POST /todos - Create todo
resource "aws_api_gateway_method" "create_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_todo" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.create_todo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_todo.invoke_arn
}

# GET /todos/{id} - Get specific todo
resource "aws_api_gateway_method" "get_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todo_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_todo" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.get_todo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.read_todo.invoke_arn
}

# PUT /todos/{id} - Update todo
resource "aws_api_gateway_method" "update_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todo_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_todo" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.update_todo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_todo.invoke_arn
}

# DELETE /todos/{id} - Delete todo
resource "aws_api_gateway_method" "delete_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todo_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_todo" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todo_id.id
  http_method = aws_api_gateway_method.delete_todo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_todo.invoke_arn
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "api_gateway_list" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_todos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_create" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_read" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_update" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_delete" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "todo_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.list_todos,
    aws_api_gateway_integration.create_todo,
    aws_api_gateway_integration.get_todo,
    aws_api_gateway_integration.update_todo,
    aws_api_gateway_integration.delete_todo,
    aws_api_gateway_integration.options,
  ]

  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage
resource "aws_api_gateway_stage" "todo_api_stage" {
  deployment_id = aws_api_gateway_deployment.todo_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  stage_name    = var.environment

  tags = {
    Name        = "Todo API Stage"
    Environment = var.environment
    Project     = "Serverless REST API"
  }
}

# Data sources for Lambda function archives
data "archive_file" "create_todo_zip" {
  type        = "zip"
  source_file = "lambda_functions/create_todo.py"
  output_path = "lambda_functions/create_todo.zip"
}

data "archive_file" "read_todo_zip" {
  type        = "zip"
  source_file = "lambda_functions/read_todo.py"
  output_path = "lambda_functions/read_todo.zip"
}

data "archive_file" "update_todo_zip" {
  type        = "zip"
  source_file = "lambda_functions/update_todo.py"
  output_path = "lambda_functions/update_todo.zip"
}

data "archive_file" "delete_todo_zip" {
  type        = "zip"
  source_file = "lambda_functions/delete_todo.py"
  output_path = "lambda_functions/delete_todo.zip"
}

data "archive_file" "list_todos_zip" {
  type        = "zip"
  source_file = "lambda_functions/list_todos.py"
  output_path = "lambda_functions/list_todos.zip"
}
