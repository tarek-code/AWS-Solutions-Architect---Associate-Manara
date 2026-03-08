# PowerShell deployment script for Serverless Todo API
# This script deploys the Terraform infrastructure and uploads the frontend

param(
    [string]$Environment = "dev",
    [string]$Region = "us-east-1",
    [switch]$SkipFrontend = $false,
    [switch]$Destroy = $false
)

Write-Host "🚀 Starting deployment of Serverless Todo API..." -ForegroundColor Green

# Check if AWS CLI is installed
try {
    aws --version | Out-Null
    Write-Host "✅ AWS CLI found" -ForegroundColor Green
}
catch {
    Write-Host "❌ AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
    exit 1
}

# Check if Terraform is installed
try {
    terraform version | Out-Null
    Write-Host "✅ Terraform found" -ForegroundColor Green
}
catch {
    Write-Host "❌ Terraform not found. Please install Terraform first." -ForegroundColor Red
    exit 1
}

# Set AWS region
$env:AWS_DEFAULT_REGION = $Region

if ($Destroy) {
    Write-Host "🗑️ Destroying infrastructure..." -ForegroundColor Yellow
    terraform destroy -var="environment=$Environment" -var="aws_region=$Region" -auto-approve
    Write-Host "✅ Infrastructure destroyed" -ForegroundColor Green
    exit 0
}

# Initialize Terraform
Write-Host "🔧 Initializing Terraform..." -ForegroundColor Yellow
terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform initialization failed" -ForegroundColor Red
    exit 1
}

# Plan Terraform deployment
Write-Host "📋 Planning Terraform deployment..." -ForegroundColor Yellow
terraform plan -var="environment=$Environment" -var="aws_region=$Region" -out=tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed" -ForegroundColor Red
    exit 1
}

# Apply Terraform deployment
Write-Host "🏗️ Applying Terraform deployment..." -ForegroundColor Yellow
terraform apply -var="environment=$Environment" -var="aws_region=$Region" -auto-approve

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform apply failed" -ForegroundColor Red
    exit 1
}

# Get outputs
Write-Host "📤 Getting Terraform outputs..." -ForegroundColor Yellow
$apiUrl = terraform output -raw api_gateway_url
$frontendBucket = terraform output -raw frontend_bucket_name
$frontendUrl = terraform output -raw frontend_website_url

Write-Host "✅ Infrastructure deployed successfully!" -ForegroundColor Green
Write-Host "🌐 API Gateway URL: $apiUrl" -ForegroundColor Cyan
Write-Host "🪣 Frontend Bucket: $frontendBucket" -ForegroundColor Cyan

if (-not $SkipFrontend) {
    # Upload frontend to S3
    Write-Host "📤 Uploading frontend to S3..." -ForegroundColor Yellow
    
    # Update the frontend with the API URL
    $indexContent = Get-Content "frontend/index.html" -Raw
    $indexContent = $indexContent -replace 'placeholder="Enter your API Gateway URL"', "placeholder=`"Enter your API Gateway URL`" value=`"$apiUrl`""
    $indexContent | Set-Content "frontend/index.html"
    
    # Upload files to S3
    aws s3 sync frontend/ s3://$frontendBucket/ --delete
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Frontend upload failed" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Frontend uploaded successfully!" -ForegroundColor Green
    Write-Host "🌐 Frontend URL: $frontendUrl" -ForegroundColor Cyan
}

Write-Host "`n🎉 Deployment completed successfully!" -ForegroundColor Green
Write-Host "`n📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Visit the frontend URL to test the application" -ForegroundColor White
Write-Host "2. Use the API Gateway URL to test the API directly" -ForegroundColor White
Write-Host "3. Check CloudWatch logs for monitoring" -ForegroundColor White
Write-Host "`n🔗 API Endpoints:" -ForegroundColor Yellow
Write-Host "GET    $apiUrl/todos - List all todos" -ForegroundColor White
Write-Host "POST   $apiUrl/todos - Create a todo" -ForegroundColor White
Write-Host "GET    $apiUrl/todos/{id} - Get a specific todo" -ForegroundColor White
Write-Host "PUT    $apiUrl/todos/{id} - Update a todo" -ForegroundColor White
Write-Host "DELETE $apiUrl/todos/{id} - Delete a todo" -ForegroundColor White
