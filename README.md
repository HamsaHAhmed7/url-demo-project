# project-demo — URL Shortener on AWS ECS Fargate

A distributed URL shortener deployed across AWS ECS Fargate with a full CI/CD pipeline.

## Architecture

```
Internet
    │
    ▼
  ALB + WAF (eu-west-2)
    │
    ├──/api/*──────► ECS API Service        (Python/FastAPI, port 8080)
    │                     │           │
    │               PostgreSQL      Redis
    │               (RDS)         (ElastiCache)
    │                               │
    │                             SQS Queue
    │                               │
    ├──/stats/*────► ECS Dashboard        (Go, port 8081)
    │                     │
    │               PostgreSQL (read-only)
    │
    └────────────── ECS Worker Service    (Go, SQS consumer)
                          │
                    PostgreSQL (write analytics)
```

All ECS tasks run in private subnets. No NAT gateways — VPC endpoints used for all AWS service traffic.

## Services

| Service   | Language | Port | Responsibility                         |
|-----------|----------|------|----------------------------------------|
| api       | Python   | 8080 | Shorten URLs, redirect, publish clicks |
| worker    | Go       | —    | Consume SQS click events, write stats  |
| dashboard | Go       | 8081 | Query analytics endpoints              |

## Local Development

```bash
docker compose up --build

# Shorten a URL
curl -X POST http://localhost:8080/api/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/long/path"}'

# Use the short code
curl -L http://localhost:8080/{short_code}

# View analytics
curl http://localhost:8081/summary
```

## Deployment

### Prerequisites

1. AWS account with billing alerts configured
2. Terraform state bootstrap (one-time):
   ```bash
   aws s3api create-bucket --bucket project-demo-tf-state --region eu-west-2 \
     --create-bucket-configuration LocationConstraint=eu-west-2
   aws s3api put-bucket-versioning --bucket project-demo-tf-state \
     --versioning-configuration Status=Enabled
   aws dynamodb create-table --table-name project-demo-tf-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST --region eu-west-2
   ```

3. GitHub Actions secrets:
   | Secret | Value |
   |--------|-------|
   | `AWS_ROLE_ARN` | ARN of the OIDC role (output from Terraform) |
   | `AWS_ROLE_SESSION_NAME` | `github-actions-deploy` |
   | `DB_PASSWORD` | RDS master password |
   | `ALERT_EMAIL` | Email for CloudWatch alerts |

### First Deploy

```bash
cd terraform
terraform init
terraform plan -var="db_password=<password>" -var="alert_email=<email>"
terraform apply
```

Subsequent deploys happen automatically on push to `main`.

## CI/CD Pipeline

- **Pull Request** → runs tests, builds images, Trivy scan, pushes PR-tagged images to ECR
- **Merge to main** → tests → build → scan → push → Terraform apply → ECS rolling update → auto-rollback on failure

Total time from merge to live: ~12 minutes.

## Infrastructure

All infrastructure is in `terraform/` using modular Terraform:

```
terraform/modules/
├── vpc          # Private subnets + VPC endpoints (no NAT)
├── ecr          # 3 container registries
├── rds          # PostgreSQL 16 on db.t3.micro
├── elasticache  # Redis 7 on cache.t3.micro
├── sqs          # click-events queue + DLQ
├── alb          # Application Load Balancer + WAF
├── iam          # Least-privilege task roles + GitHub OIDC
├── ecs          # Fargate cluster + 3 services + auto-scaling
└── monitoring   # CloudWatch dashboard + alarms → SNS → email
```
