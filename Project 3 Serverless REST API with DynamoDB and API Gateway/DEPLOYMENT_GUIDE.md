# Deployment Guide - Serverless Todo API

This guide provides step-by-step instructions for deploying the Serverless Todo API using Terraform.

## Prerequisites

Before starting, ensure you have the following installed and configured:

### 1. AWS CLI
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
```

### 2. Terraform
```bash
# Install Terraform (Linux/Mac)
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

### 3. Required AWS Permissions
Your AWS user/role needs the following permissions:
- IAM (create roles and policies)
- Lambda (create and manage functions)
- API Gateway (create and manage APIs)
- DynamoDB (create and manage tables)
- S3 (create buckets and manage objects)
- CloudWatch (create log groups)

## Quick Deployment

### Option 1: Using Deployment Scripts

**Windows (PowerShell):**
```powershell
.\deploy.ps1 -Environment dev -Region us-east-1
```

**Linux/Mac (Bash):**
```bash
./deploy.sh --environment dev --region us-east-1
```

### Option 2: Manual Deployment

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Plan the deployment:**
```bash
terraform plan -var="environment=dev" -var="aws_region=us-east-1"
```

3. **Apply the configuration:**
```bash
terraform apply -var="environment=dev" -var="aws_region=us-east-1"
```

4. **Upload the frontend:**
```bash
# Get the S3 bucket name
FRONTEND_BUCKET=$(terraform output -raw frontend_bucket_name)

# Upload frontend files
aws s3 sync frontend/ s3://$FRONTEND_BUCKET/ --delete
```

## Configuration

### Environment Variables

Create a `terraform.tfvars` file to customize your deployment:

```hcl
# terraform.tfvars
aws_region = "us-west-2"
environment = "production"
project_name = "my-todo-app"
lambda_timeout = 60
lambda_memory_size = 256
log_retention_days = 30
```

### Available Variables

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `aws_region` | AWS region for resources | `us-east-1` | string |
| `environment` | Environment name | `dev` | string |
| `project_name` | Name of the project | `serverless-todo-api` | string |
| `table_name` | DynamoDB table name | `todo-items` | string |
| `api_name` | API Gateway name | `todo-api` | string |
| `lambda_timeout` | Lambda timeout in seconds | `30` | number |
| `lambda_memory_size` | Lambda memory in MB | `128` | number |
| `log_retention_days` | CloudWatch log retention | `14` | number |

## Post-Deployment

### 1. Get Deployment Information

```bash
# Get all outputs
terraform output

# Get specific outputs
terraform output api_gateway_url
terraform output frontend_website_url
terraform output dynamodb_table_name
```

### 2. Test the API

**Using the test script:**
```bash
# PowerShell
.\test-api.ps1 -ApiUrl "https://your-api-id.execute-api.us-east-1.amazonaws.com/dev"

# Bash
./test-api.sh "https://your-api-id.execute-api.us-east-1.amazonaws.com/dev"
```

**Manual testing:**
```bash
# List todos
curl https://your-api-id.execute-api.us-east-1.amazonaws.com/dev/todos

# Create a todo
curl -X POST https://your-api-id.execute-api.us-east-1.amazonaws.com/dev/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Todo", "description": "This is a test"}'
```

### 3. Access the Frontend

1. Get the frontend URL from Terraform outputs
2. Open the URL in your browser
3. Enter the API Gateway URL when prompted
4. Start using the application!

## Monitoring

### CloudWatch Logs

Monitor your Lambda functions:
```bash
# List log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/todo-"

# View logs for a specific function
aws logs tail /aws/lambda/todo-create-xxxxx --follow
```

### API Gateway Monitoring

- Go to API Gateway console
- Select your API
- View metrics and logs
- Monitor request/response times

### DynamoDB Monitoring

- Go to DynamoDB console
- Select your table
- View metrics and capacity usage

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**
   - Check IAM permissions
   - Ensure your AWS credentials are configured correctly

2. **Lambda Function Errors**
   - Check CloudWatch logs
   - Verify environment variables
   - Check IAM role permissions

3. **API Gateway CORS Issues**
   - Ensure CORS is configured in Lambda functions
   - Check API Gateway CORS settings

4. **DynamoDB Access Issues**
   - Verify table name in environment variables
   - Check IAM permissions for DynamoDB

### Debug Commands

```bash
# Check Terraform state
terraform show

# List all resources
terraform state list

# Get specific resource details
terraform state show aws_dynamodb_table.todo_table

# Check AWS resources
aws lambda list-functions --query 'Functions[?contains(FunctionName, `todo`)]'
aws apigateway get-rest-apis --query 'items[?contains(name, `todo`)]'
aws dynamodb list-tables --query 'TableNames[?contains(@, `todo`)]'
```

## Cleanup

To destroy all resources:

```bash
# Using deployment script
./deploy.sh --destroy

# Or manually
terraform destroy -var="environment=dev" -var="aws_region=us-east-1"
```

**Warning:** This will permanently delete all resources and data!

## Cost Estimation

Approximate monthly costs (us-east-1):

- **DynamoDB**: $0.25 per million read/write requests
- **Lambda**: $0.20 per million requests + $0.0000166667 per GB-second
- **API Gateway**: $3.50 per million API calls
- **S3**: $0.023 per GB stored + $0.0004 per 1,000 requests
- **CloudWatch**: $0.50 per GB of log data ingested

For a small application with < 1M requests/month: **~$5-10/month**

## Security Considerations

1. **IAM Roles**: Uses least privilege access
2. **DynamoDB**: Encryption at rest enabled
3. **API Gateway**: CORS configured for security
4. **Lambda**: VPC not required for this use case
5. **S3**: Public read access for static website hosting

## Next Steps

1. **Add Authentication**: Implement API keys or Cognito
2. **Add Monitoring**: Set up CloudWatch alarms
3. **Add CI/CD**: Implement automated deployment
4. **Add Testing**: Implement automated testing
5. **Add Documentation**: Generate API documentation

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review CloudWatch logs
3. Check Terraform state
4. Open an issue in the repository
