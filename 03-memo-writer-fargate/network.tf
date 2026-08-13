# Networking — the course says: learn enough to deploy, don't disappear into VPC-land.
# Strategy: USE THE DEFAULT VPC via data sources (read, not create — Week 1 concept).
# Building a VPC from scratch is a Phase 3 problem.

# TODO 1: look up the default VPC and its subnets
# - data "aws_vpc" with `default = true`
# - data "aws_subnets" filtered to that vpc-id
#   (the ALB needs subnets in >= 2 availability zones; the default VPC has one per AZ)

# TODO 2: security group for the ALB
# Resource: aws_security_group (+ aws_vpc_security_group_ingress_rule / egress_rule)
# - ingress: TCP 80 from 0.0.0.0/0  (the internet reaches the ALB)
# - egress: allow all               (ALB must reach the tasks)

# TODO 3: security group for the Fargate service
# - ingress: TCP 8080 ONLY from the ALB's security group (reference the SG ID,
#   not a CIDR — "who may talk to me" expressed as an identity, not an address.
#   This is the least-privilege idea applied to networking.)
# - egress: allow all (the app needs to reach DynamoDB, Secrets Manager, Anthropic)
