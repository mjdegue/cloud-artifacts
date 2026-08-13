# TODO: the log group — MANAGED BY TERRAFORM THIS TIME.
# Week 2's straggler lesson: Lambda auto-created its log group and destroy left it
# behind. This week you create it explicitly:
#
# Resource: aws_cloudwatch_log_group
# - name: e.g. "/ecs/memo-writer"  (the task definition's log config must match!)
# - retention_in_days: pick one (e.g. 7). Default is NEVER EXPIRE — the TTL
#   lesson, applied to logs.
#
# Now it's in state, it gets destroyed with everything else, and retention is policy.
