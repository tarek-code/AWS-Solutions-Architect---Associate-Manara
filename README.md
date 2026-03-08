# AWS Solutions Architect - Associate | Manara Graduation Project

**Author:** Tarek Adel Ali 
**Email:** tarekadel314@gmail.com  
**LinkedIn:** [Tarek Adel](https://www.linkedin.com/in/tarek-adel-857279197/)

---

## Project Overview

This repository contains the graduation project for the AWS Solutions Architect - Associate program. The course offers three project ideas — this repository implements **Project 3**.

## Graduation Project Options

| Project | Architecture | Description |
|---------|--------------|-------------|
| **Project 1** | EC2-based | Scalable Web Application with ALB and Auto Scaling — EC2, ALB, ASG, optional RDS, CloudWatch, SNS |
| **Project 2** | Serverless | Serverless Image Processing with S3 and Lambda — S3 triggers, Lambda (resize, watermark), optional API Gateway, DynamoDB, Step Functions |
| **Project 3** | Serverless | Serverless REST API with DynamoDB and API Gateway — API Gateway, Lambda, DynamoDB, S3 frontend hosting |

**This repository implements Project 3.**

## Implemented Project (Project 3)

**Serverless REST API with DynamoDB and API Gateway** — A complete serverless to-do application using Amazon API Gateway, AWS Lambda, DynamoDB, and S3 for frontend hosting.

### Key Features

- Full CRUD operations for to-do items
- Serverless architecture (no servers to manage)
- Infrastructure as Code with Terraform
- Scalable, event-driven design
- Frontend hosted on S3

## Repository Structure

```
├── Project 1 Scalable Web Application with ALB and Auto Scaling/
│   └── ...                     # EC2, ALB, ASG
├── Project 2 Serverless Image Processing with S3 and Lambda/
│   └── ...                     # S3, Lambda image processing
├── Project 3 Serverless REST API with DynamoDB and API Gateway/  ← Implemented
│   ├── main.tf                 # Terraform infrastructure
│   ├── lambda_functions/       # Lambda source code
│   ├── frontend/               # Web application
│   ├── docs/
│   │   └── architecture-diagram.svg   # Solution architecture diagram
│   └── README.md               # Project documentation
└── README.md                   # This file
```

## Solution Architecture Diagram

![Architecture Diagram](Project%203%20Serverless%20REST%20API%20with%20DynamoDB%20and%20API%20Gateway/docs/architecture-diagram.svg)

## Project Documentation

- **[Project 1](Project%201%20Scalable%20Web%20Application%20with%20ALB%20and%20Auto%20Scaling/README.md)** — Scalable Web Application (EC2, ALB, ASG)
- **[Project 2](Project%202%20Serverless%20Image%20Processing%20with%20S3%20and%20Lambda/README.md)** — Serverless Image Processing (S3, Lambda)
- **[Project 3 - Full Documentation](Project%203%20Serverless%20REST%20API%20with%20DynamoDB%20and%20API%20Gateway/README.md)** — Serverless REST API (implemented) — Deployment guide, API reference, architecture
- **[Project 3 - Deployment Guide](Project%203%20Serverless%20REST%20API%20with%20DynamoDB%20and%20API%20Gateway/DEPLOYMENT_GUIDE.md)** — Step-by-step deployment instructions

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd AWS-Solutions-Architect---Associate-Manara
   ```

2. **Navigate to Project 3:**
   ```bash
   cd "Project 3 Serverless REST API with DynamoDB and API Gateway"
   ```

3. **Deploy with Terraform:**
   ```bash
   terraform init
   terraform plan -var="environment=dev"
   terraform apply -var="environment=dev"
   ```

4. **Upload frontend to S3** (see [Deployment Guide](Project%203%20Serverless%20REST%20API%20with%20DynamoDB%20and%20API%20Gateway/DEPLOYMENT_GUIDE.md))

## AWS Services Used

| Service | Purpose |
|---------|---------|
| API Gateway | REST API endpoints |
| Lambda | Serverless compute (CRUD logic) |
| DynamoDB | NoSQL database |
| S3 | Frontend static hosting |
| IAM | Roles and permissions |
| CloudWatch | Logging and monitoring |

## Deliverables

- ✅ Solution Architecture Diagram (visual SVG + ASCII)
- ✅ Complete project documentation in README
- ✅ Terraform Infrastructure as Code
- ✅ GitHub repository with full source code

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
