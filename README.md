# AWS Solutions Architect - Associate | Manara Graduation Project

**Author:** Tarek Adel Ali  
**Email:** tarekadel314@gmail.com  
**LinkedIn:** [Tarek Adel](https://www.linkedin.com/in/tarek-adel-857279197/)

---

## Project Overview

This repository contains the graduation project for the AWS Solutions Architect - Associate program. It includes implementations of **all three** graduation project ideas.

---

## Project 1: Scalable Web Application with ALB and Auto Scaling

**Architecture:** EC2-based

EC2-based web application with high availability using Application Load Balancer (ALB) and Auto Scaling Group (ASG).

### What's Implemented

- **VPC & Networking** — 1 VPC, 2 public subnets across AZs, Internet Gateway
- **Compute** — Launch template (Amazon Linux 2), ASG (min 1, max 2, desired 2)
- **Load Balancing** — Application Load Balancer with HTTP listener
- **Database** — Optional MySQL RDS (single-AZ) for demo
- **Monitoring** — CloudWatch CPU alarm → SNS → email subscription
- **IAM** — SSM instance profile for EC2 management

### Key Services

EC2, ALB, ASG, RDS (optional), VPC, CloudWatch, SNS, IAM

**[→ Project 1 Documentation](Project%201%20Scalable%20Web%20Application%20with%20ALB%20and%20Auto%20Scaling/README.md)**

---

## Project 2: Serverless Image Processing with S3 and Lambda

**Architecture:** Serverless

Event-driven image processing: upload images to S3, Lambda automatically resizes and watermarks them, then stores results in another S3 bucket.

### What's Implemented

- **S3 Triggers** — Original bucket triggers Lambda on image upload
- **Lambda Function** — Python 3.11 with Pillow: resize (max 800×600), add watermark, convert to JPEG
- **Dual S3 Buckets** — Original (input) and processed (output) buckets
- **Security** — Private buckets, IAM least privilege, encryption at rest
- **Monitoring** — CloudWatch logs for debugging

### Key Services

S3, Lambda, IAM, CloudWatch

**[→ Project 2 Documentation](Project%202%20Serverless%20Image%20Processing%20with%20S3%20and%20Lambda/README.md)**

---

## Project 3: Serverless REST API with DynamoDB and API Gateway

**Architecture:** Serverless

Full serverless to-do application with REST API, DynamoDB backend, and S3-hosted frontend.

### What's Implemented

- **API Gateway** — REST endpoints for CRUD operations (`/todos`, `/todos/{id}`)
- **Lambda Functions** — Create, read, update, delete, list (5 Python functions)
- **DynamoDB** — NoSQL table for todo items
- **S3 Frontend** — Static website hosting with HTML/CSS/JS
- **IAM** — Least-privilege roles, CloudWatch logging

### Key Services

API Gateway, Lambda, DynamoDB, S3, IAM, CloudWatch

### Solution Architecture Diagram

![Architecture Diagram](Project%203%20Serverless%20REST%20API%20with%20DynamoDB%20and%20API%20Gateway/docs/architecture-diagram.svg)

**[→ Project 3 Documentation](Project%203%20Serverless%20REST%20API%20with%20DynamoDB%20and%20API%20Gateway/README.md)** | **[Deployment Guide](Project%203%20Serverless%20REST%20API%20with%20DynamoDB%20and%20API%20Gateway/DEPLOYMENT_GUIDE.md)**

---

## Repository Structure

```
├── Project 1 Scalable Web Application with ALB and Auto Scaling/
│   ├── main.tf                 # Terraform (VPC, EC2, ALB, ASG, RDS, SNS)
│   └── README.md
├── Project 2 Serverless Image Processing with S3 and Lambda/
│   ├── main.tf                 # Terraform (S3, Lambda)
│   ├── lambda_function.py      # Image processing logic
│   └── README.md
├── Project 3 Serverless REST API with DynamoDB and API Gateway/
│   ├── main.tf                 # Terraform (API Gateway, Lambda, DynamoDB, S3)
│   ├── lambda_functions/       # CRUD Lambda functions
│   ├── frontend/               # Web application
│   ├── docs/
│   │   └── architecture-diagram.svg
│   ├── README.md
│   └── DEPLOYMENT_GUIDE.md
└── README.md                   # This file
```

---

## Deliverables

- Solution architecture diagrams for each project
- Complete documentation in each project's README
- Terraform Infrastructure as Code for all three projects
- GitHub repository with full source code

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
