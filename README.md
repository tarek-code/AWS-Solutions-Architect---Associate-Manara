# AWS Solutions Architect - Associate | Manara Graduation Project

**Author:** Ayman Aly Mahmoud  
**Email:** ayman@manara.tech  
**LinkedIn:** [Ayman Mahmoud](https://linkedin.com/in/ayman-mahmoud)

---

## Project Overview

This repository contains the graduation project for the AWS Solutions Architect - Associate program. The project implements **Project 3: Serverless REST API with DynamoDB and API Gateway**.

## Project Selection

**Project 3: Serverless REST API with DynamoDB and API Gateway** — A complete serverless to-do application using Amazon API Gateway, AWS Lambda, DynamoDB, and S3 for frontend hosting.

### Key Features

- Full CRUD operations for to-do items
- Serverless architecture (no servers to manage)
- Infrastructure as Code with Terraform
- Scalable, event-driven design
- Frontend hosted on S3

## Repository Structure

```
├── Project 3 Serverless REST API with DynamoDB and API Gateway/
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

- **[Project 3 - Full Documentation](Project%203%20Serverless%20REST%20API%20with%20DynamoDB%20and%20API%20Gateway/README.md)** — Deployment guide, API reference, and architecture details
- **[Deployment Guide](Project%203%20Serverless%20REST%20API%20with%20DynamoDB%20and%20API%20Gateway/DEPLOYMENT_GUIDE.md)** — Step-by-step deployment instructions

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
