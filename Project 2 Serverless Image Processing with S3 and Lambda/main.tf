# Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
  }
}


provider "aws" {
  region = "us-east-1" # Free tier region
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket for original images
resource "aws_s3_bucket" "original_images" {
  bucket = "original-images-${random_string.suffix.result}"

  tags = {
    Name        = "Original Images Bucket"
    Environment = "Free Tier"
    Project     = "Serverless Image Processing"
  }
}

# S3 bucket for processed images
resource "aws_s3_bucket" "processed_images" {
  bucket = "processed-images-${random_string.suffix.result}"

  tags = {
    Name        = "Processed Images Bucket"
    Environment = "Free Tier"
    Project     = "Serverless Image Processing"
  }
}

# S3 bucket versioning for original images
resource "aws_s3_bucket_versioning" "original_images" {
  bucket = aws_s3_bucket.original_images.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket versioning for processed images
resource "aws_s3_bucket_versioning" "processed_images" {
  bucket = aws_s3_bucket.processed_images.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket public access block for original images
resource "aws_s3_bucket_public_access_block" "original_images" {
  bucket = aws_s3_bucket.original_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket public access block for processed images
resource "aws_s3_bucket_public_access_block" "processed_images" {
  bucket = aws_s3_bucket.processed_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "image-processing-lambda-role-${random_string.suffix.result}"

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
    Name        = "Image Processing Lambda Role"
    Environment = "Free Tier"
    Project     = "Serverless Image Processing"
  }
}

# IAM policy for Lambda function
resource "aws_iam_policy" "lambda_policy" {
  name        = "image-processing-lambda-policy-${random_string.suffix.result}"
  description = "Policy for image processing Lambda function"

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
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.original_images.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.processed_images.arn}/*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Attach basic execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create deployment package for Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Lambda function
resource "aws_lambda_function" "image_processor" {
  filename         = "lambda_function.zip"
  function_name    = "image-processor-${random_string.suffix.result}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 256 # Free tier: 128MB-1024MB

  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_images.bucket
    }
  }

  tags = {
    Name        = "Image Processor Lambda"
    Environment = "Free Tier"
    Project     = "Serverless Image Processing"
  }
}

# Lambda permission for S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.original_images.arn
}

# S3 bucket notification to trigger Lambda
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.original_images.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpeg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".png"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.image_processor.function_name}"
  retention_in_days = 7 # Free tier: 7 days retention

  tags = {
    Name        = "Image Processor Lambda Logs"
    Environment = "Free Tier"
    Project     = "Serverless Image Processing"
  }
}

# Output values
output "original_bucket_name" {
  description = "Name of the original images S3 bucket"
  value       = aws_s3_bucket.original_images.bucket
}

output "processed_bucket_name" {
  description = "Name of the processed images S3 bucket"
  value       = aws_s3_bucket.processed_images.bucket
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.image_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.image_processor.arn
}

output "instructions" {
  description = "Instructions for using the image processing system"
  value       = <<-EOT
    Image Processing System Setup Complete!
    
    To use this system:
    1. Upload images to: ${aws_s3_bucket.original_images.bucket}
    2. Processed images will appear in: ${aws_s3_bucket.processed_images.bucket}/processed/
    3. Supported formats: JPG, JPEG, PNG
    4. Images will be resized to max 800x600 and watermarked
    
    Free Tier Usage:
    - S3: 5GB storage, 20,000 GET requests, 2,000 PUT requests
    - Lambda: 1M requests, 400,000 GB-seconds compute time
    - CloudWatch Logs: 5GB log data ingestion, 7 days retention
  EOT
}
