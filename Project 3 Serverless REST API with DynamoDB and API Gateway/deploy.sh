#!/bin/bash

# Bash deployment script for Serverless Todo API
# This script deploys the Terraform infrastructure and uploads the frontend

set -e

# Default values
ENVIRONMENT="dev"
REGION="us-east-1"
SKIP_FRONTEND=false
DESTROY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        --skip-frontend)
            SKIP_FRONTEND=true
            shift
            ;;
        --destroy)
            DESTROY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -e, --environment ENV    Environment name (default: dev)"
            echo "  -r, --region REGION      AWS region (default: us-east-1)"
            echo "  --skip-frontend          Skip frontend upload"
            echo "  --destroy                Destroy infrastructure"
            echo "  -h, --help               Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

echo "🚀 Starting deployment of Serverless Todo API..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    exit 1
fi
echo "✅ AWS CLI found"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install Terraform first."
    exit 1
fi
echo "✅ Terraform found"

# Set AWS region
export AWS_DEFAULT_REGION=$REGION

if [ "$DESTROY" = true ]; then
    echo "🗑️ Destroying infrastructure..."
    terraform destroy -var="environment=$ENVIRONMENT" -var="aws_region=$REGION" -auto-approve
    echo "✅ Infrastructure destroyed"
    exit 0
fi

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Plan Terraform deployment
echo "📋 Planning Terraform deployment..."
terraform plan -var="environment=$ENVIRONMENT" -var="aws_region=$REGION" -out=tfplan

# Apply Terraform deployment
echo "🏗️ Applying Terraform deployment..."
terraform apply -var="environment=$ENVIRONMENT" -var="aws_region=$REGION" -auto-approve

# Get outputs
echo "📤 Getting Terraform outputs..."
API_URL=$(terraform output -raw api_gateway_url)
FRONTEND_BUCKET=$(terraform output -raw frontend_bucket_name)
FRONTEND_URL=$(terraform output -raw frontend_website_url)

echo "✅ Infrastructure deployed successfully!"
echo "🌐 API Gateway URL: $API_URL"
echo "🪣 Frontend Bucket: $FRONTEND_BUCKET"

if [ "$SKIP_FRONTEND" = false ]; then
    # Upload frontend to S3
    echo "📤 Uploading frontend to S3..."
    
    # Update the frontend with the API URL
    sed -i.bak "s/placeholder=\"Enter your API Gateway URL\"/placeholder=\"Enter your API Gateway URL\" value=\"$API_URL\"/g" frontend/index.html
    
    # Upload files to S3
    aws s3 sync frontend/ s3://$FRONTEND_BUCKET/ --delete
    
    echo "✅ Frontend uploaded successfully!"
    echo "🌐 Frontend URL: $FRONTEND_URL"
fi

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Visit the frontend URL to test the application"
echo "2. Use the API Gateway URL to test the API directly"
echo "3. Check CloudWatch logs for monitoring"
echo ""
echo "🔗 API Endpoints:"
echo "GET    $API_URL/todos - List all todos"
echo "POST   $API_URL/todos - Create a todo"
echo "GET    $API_URL/todos/{id} - Get a specific todo"
echo "PUT    $API_URL/todos/{id} - Update a todo"
echo "DELETE $API_URL/todos/{id} - Delete a todo"
