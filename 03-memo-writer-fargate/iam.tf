# ECS needs TWO roles, and the distinction is a classic interview question:
#
#   EXECUTION ROLE — used by the ECS *agent* to SET UP your container:
#     pull the image from ECR, create/write log streams, fetch secrets it
#     injects as env vars. The platform's permissions.
#
#   TASK ROLE — used by YOUR CODE at runtime (boto3 inherits it, exactly like
#     the Lambda role in Week 2): DynamoDB access, Secrets Manager access.
#     The application's permissions.
#
# Same trust-policy skill as Week 2, new principal: "ecs-tasks.amazonaws.com"
# (both roles trust it).

# TODO 1: execution role
# - trust: ecs-tasks.amazonaws.com
# - permissions: AWS provides a managed policy for this —
#   "AmazonECSTaskExecutionRolePolicy" — attach it via
#   aws_iam_role_policy_attachment + its well-known ARN
#   (arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy).
#   First time using a MANAGED policy instead of writing your own: know the trade —
#   convenient, maintained by AWS, but broader than hand-rolled least privilege.

# TODO 2: task role
# - trust: ecs-tasks.amazonaws.com
# - permissions: hand-rolled, least-privilege, exactly like Week 2's Lambda policy:
#   dynamodb Put/Get/DeleteItem on the table ARN, secretsmanager:GetSecretValue
#   on the secret ARN. (No logs statements here — logging goes through the
#   awslogs driver using the EXECUTION role. Think about why.)
