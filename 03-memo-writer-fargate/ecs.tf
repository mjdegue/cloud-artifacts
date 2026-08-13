# The compute: cluster (namespace) -> task definition (blueprint) -> service (keeper).

# TODO 1: the cluster
# Resource: aws_ecs_cluster — just a name. It's a namespace, not machines
# (that's the entire point of Fargate: there are no machines you can see).

# TODO 2: the task definition — the "what to run" blueprint
# Resource: aws_ecs_task_definition
# - requires_compatibilities = ["FARGATE"], network_mode = "awsvpc"
# - cpu = 256, memory = 512  (the smallest size; ~$9/mo if left running 24/7)
# - execution_role_arn + task_role_arn: the two roles from iam.tf (order matters —
#   mixing them up produces confusing failures at image-pull or at runtime)
# - container_definitions = jsonencode([{ ... }]) with:
#     name, image (the ECR repo URL + ":latest"),
#     portMappings [{containerPort = 8080}],
#     environment: TABLE_NAME, SECRET_NAME (same contract as Week 2's Lambda),
#     logConfiguration: awslogs driver -> the log group from cloudwatch.tf,
#       awslogs-region, awslogs-stream-prefix
#   NOTE: container_definitions is JSON-in-HCL (like Week 1's bucket policy via
#   jsonencode) and its keys are camelCase — it's the raw ECS API schema.

# TODO 3: the service — "keep N copies alive and registered with the ALB"
# Resource: aws_ecs_service
# - desired_count = 1, launch_type = "FARGATE"
# - network_configuration: the default-VPC subnets + the SERVICE security group;
#   assign_public_ip = true  (required in the default VPC so the task can pull
#   the image / reach AWS APIs — no NAT gateway here. Note it; don't love it.)
# - load_balancer block: target group ARN + container name + port 8080
# - depends_on the listener (the service registers targets; the listener must exist)
#
# The service is the self-healing part: kill the task, watch ECS start another.
# Try it once — it's the demo that explains why this costs more than Lambda.
