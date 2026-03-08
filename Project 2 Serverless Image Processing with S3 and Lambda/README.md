# 🖼️ Serverless Image Processing with AWS S3 and Lambda

A complete serverless image processing solution that automatically resizes and watermarks images uploaded to S3 using AWS Lambda. Built with Terraform for infrastructure as code and designed to work within AWS Free Tier limits.

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User Uploads  │───▶│   S3 Bucket      │───▶│  Lambda Function│
│   Image File    │    │  (Original)      │    │  (Image Processor)│
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                │                        ▼
                                │                ┌─────────────────┐
                                │                │  Image Processing│
                                │                │  • Resize to 800x600│
                                │                │  • Add Watermark │
                                │                │  • Convert to JPEG│
                                │                └─────────────────┘
                                │                        │
                                │                        ▼
                                │                ┌─────────────────┐
                                │                │   S3 Bucket     │
                                │                │  (Processed)    │
                                │                └─────────────────┘
```

## ✨ Features

- **🔄 Automatic Processing**: Images are processed automatically upon upload
- **📏 Smart Resizing**: Maintains aspect ratio, resizes to max 800x600 pixels
- **🏷️ Watermarking**: Adds "Processed by AWS Lambda" watermark
- **📁 Format Support**: JPG, JPEG, PNG, GIF, BMP
- **💰 Free Tier Compatible**: Designed to stay within AWS Free Tier limits
- **🔒 Secure**: Private S3 buckets with proper IAM permissions
- **📊 Monitoring**: CloudWatch logs for debugging and monitoring

## 🛠️ Tech Stack

- **Infrastructure**: Terraform
- **Compute**: AWS Lambda (Python 3.11)
- **Storage**: Amazon S3
- **Image Processing**: Pillow (PIL)
- **Monitoring**: CloudWatch Logs
- **Security**: IAM Roles & Policies

## 📋 Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Python 3.11+ (for local development)
- Git

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd serverless-image-processing
```

### 2. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 3. Upload Images
```bash
# Upload an image to trigger processing
aws s3 cp your-image.jpg s3://original-images-<random-suffix>/
```

### 4. View Processed Images
```bash
# List processed images
aws s3 ls s3://processed-images-<random-suffix>/processed/ --recursive
```

## 📁 Project Structure

```
serverless-image-processing/
├── main.tf                 # Terraform infrastructure configuration
├── lambda_function.py      # Lambda function code
├── requirements.txt        # Python dependencies
├── lambda_function.zip     # Lambda deployment package (auto-generated)
├── .gitignore             # Git ignore rules
└── README.md              # This file
```

## 🔧 Configuration

### Lambda Function Settings
- **Runtime**: Python 3.11
- **Memory**: 256 MB
- **Timeout**: 30 seconds
- **Environment Variables**:
  - `PROCESSED_BUCKET`: Target bucket for processed images

### S3 Bucket Configuration
- **Versioning**: Enabled
- **Encryption**: AES-256
- **Public Access**: Blocked
- **Event Triggers**: Object creation events for image files

## 📊 AWS Free Tier Usage

| Service | Free Tier Limit | Project Usage |
|---------|----------------|---------------|
| S3 Storage | 5 GB | ~1-2 GB |
| S3 Requests | 20,000 GET, 2,000 PUT | ~100-500 requests |
| Lambda Invocations | 1M requests | ~10-100 requests |
| Lambda Duration | 400,000 GB-seconds | ~1-10 GB-seconds |
| CloudWatch Logs | 5 GB | ~0.1-1 GB |

## 🔍 Monitoring & Debugging

### View Lambda Logs
```bash
# Get the Lambda function name from Terraform output
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/image-processor"

# View recent logs
aws logs tail /aws/lambda/image-processor-<suffix> --follow
```

### Test Image Processing
```bash
# Upload a test image
aws s3 cp test-image.jpg s3://original-images-<suffix>/

# Check processing status
aws logs tail /aws/lambda/image-processor-<suffix> --since 5m
```

## 🛡️ Security Features

- **Private S3 Buckets**: No public access allowed
- **IAM Least Privilege**: Lambda has minimal required permissions
- **Encryption**: All data encrypted at rest
- **VPC**: Lambda runs in AWS managed VPC
- **Resource Isolation**: Unique resource names prevent conflicts

## 🔄 Image Processing Details

### Supported Formats
- **Input**: JPG, JPEG, PNG, GIF, BMP
- **Output**: JPEG (optimized, 85% quality)

### Processing Steps
1. **Download**: Image retrieved from source S3 bucket
2. **Convert**: Convert to RGB format for JPEG compatibility
3. **Resize**: Maintain aspect ratio, max dimensions 800x600
4. **Watermark**: Add "Processed by AWS Lambda" text
5. **Upload**: Save to processed S3 bucket

### Watermark Specifications
- **Text**: "Processed by AWS Lambda"
- **Position**: Bottom-right corner
- **Background**: Semi-transparent white rectangle
- **Font**: System default or Arial (if available)

## 🧹 Cleanup

To destroy all resources and avoid charges:

```bash
# Destroy all infrastructure
terraform destroy

# Confirm destruction
terraform destroy -auto-approve
```

## 🐛 Troubleshooting

### Common Issues

1. **Lambda Import Error**
   ```bash
   # Rebuild the deployment package
   terraform apply -replace=aws_lambda_function.image_processor
   ```

2. **S3 Bucket Not Empty**
   ```bash
   # Empty buckets before destroy
   aws s3 rm s3://bucket-name --recursive
   ```

3. **Permission Denied**
   ```bash
   # Check AWS credentials
   aws sts get-caller-identity
   ```

### Debug Commands

```bash
# Check Lambda function status
aws lambda get-function --function-name image-processor-<suffix>

# Test Lambda function
aws lambda invoke --function-name image-processor-<suffix> response.json

# List S3 objects
aws s3 ls s3://original-images-<suffix>/ --recursive
aws s3 ls s3://processed-images-<suffix>/processed/ --recursive
```

## 📈 Performance Optimization

- **Memory**: 256 MB (sufficient for most images)
- **Timeout**: 30 seconds (handles large images)
- **Concurrency**: Unlimited (auto-scales)
- **Cold Start**: ~2-3 seconds (acceptable for batch processing)

## 🔮 Future Enhancements

- [ ] Support for more image formats (WebP, TIFF)
- [ ] Multiple resize options (thumbnails, different sizes)
- [ ] Advanced watermarking (images, positioning)
- [ ] Image optimization (compression, quality settings)
- [ ] Batch processing capabilities
- [ ] API Gateway integration for web uploads
- [ ] CloudFront distribution for CDN
- [ ] SNS notifications for processing completion

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For questions or issues:
- Create an issue in the repository
- Check AWS CloudWatch logs for debugging
- Review Terraform documentation for infrastructure issues

## 🙏 Acknowledgments

- AWS for providing excellent serverless services
- Terraform for infrastructure as code capabilities
- Python Pillow library for image processing
- The open-source community for inspiration and tools

---

**Happy Image Processing! 🎉**

*Built with ❤️ using AWS Serverless technologies*
