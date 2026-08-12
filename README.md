# cloud-artifacts

Hands-on AWS builds — everything provisioned with Terraform, no console click-ops.

Part of a self-directed AI Platform Engineering program: cloud infrastructure, containerized Python services, and LLM-powered APIs deployed on AWS.

## Artifacts

| # | Artifact | Stack | Status |
|---|----------|-------|--------|
| 1 | S3 module — versioned, encrypted bucket with policy-enforced encryption, least-privilege IAM verified empirically | Terraform, S3, IAM, boto3 | ✅ Done |
| 2 | AI Memo Writer — serverless LLM API: Lambda + API Gateway + DynamoDB + Secrets Manager | Terraform, Lambda, API Gateway, DynamoDB, Claude API | In progress |

*(More coming: ECS Fargate streaming API.)*

## Conventions

- Every artifact stands up from empty state with `terraform apply` and tears down cleanly with `terraform destroy`.
- IAM roles are least-privilege — each service gets exactly what it needs.
- All resources carry cost-allocation tags.
