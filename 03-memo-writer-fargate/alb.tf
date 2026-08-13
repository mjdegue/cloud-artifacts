# The Application Load Balancer — three resources. THIS is the ~$16/month piece:
# it bills per hour while it exists, unlike everything else you've built.
# `terraform destroy` between sessions is your cost lever.

# TODO 1: the load balancer itself
# Resource: aws_lb
# - load_balancer_type "application", internal = false
# - security_groups: the ALB SG from network.tf
# - subnets: the default-VPC subnet IDs (needs >= 2 AZs)

# TODO 2: the target group — "who do I forward to, and how do I know they're alive"
# Resource: aws_lb_target_group
# - port 8080, protocol "HTTP", vpc_id from the data source
# - target_type "ip"  — REQUIRED for Fargate (tasks are IPs, not instances).
#   The ECS service registers/deregisters task IPs here automatically.
# - health_check block: path "/health", and think about interval/thresholds.
#   The ALB polls this endpoint forever; unhealthy targets get killed and
#   replaced by ECS. Your app's /health endpoint is load-bearing infrastructure.

# TODO 3: the listener — "what do I do with traffic on port 80"
# Resource: aws_lb_listener
# - port 80, protocol "HTTP" (HTTPS needs a cert + domain — Phase 3 material)
# - default_action: forward to the target group
