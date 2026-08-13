# cloud-artifacts

Hands-on AWS builds — everything provisioned with Terraform, no console click-ops.

Part of a self-directed AI Platform Engineering program: cloud infrastructure, containerized Python services, and LLM-powered APIs deployed on AWS.

## Artifacts

| # | Artifact | Stack | Status |
|---|----------|-------|--------|
| 1 | S3 module — versioned, encrypted bucket with policy-enforced encryption, least-privilege IAM verified empirically | Terraform, S3, IAM, boto3 | ✅ Done |
| 2 | AI Memo Writer — serverless LLM API: Lambda + API Gateway + DynamoDB + Secrets Manager, least-privilege IAM, TTL persistence | Terraform, Lambda, API Gateway, DynamoDB, Secrets Manager, Claude API | ✅ Done |
| 3 | AI Memo Writer v2 — containerized streaming LLM API: FastAPI on ECS Fargate behind an ALB, SSE token streaming | Terraform, Docker, ECS Fargate, ECR, ALB, FastAPI, Claude API | In progress |

## Conventions

- Every artifact stands up from empty state with `terraform apply` and tears down cleanly with `terraform destroy`.
- IAM roles are least-privilege — each service gets exactly what it needs.
- All resources carry cost-allocation tags.
