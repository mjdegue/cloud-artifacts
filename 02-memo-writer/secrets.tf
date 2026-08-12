# TODO: the Anthropic API key secret — CONTAINER ONLY, no value
# Resource type: aws_secretsmanager_secret
#
# IMPORTANT design decision (same lesson as Week 1's access keys):
# Terraform creates the *container*; the VALUE goes in via CLI, one time, so the
# key never touches your .tf files or terraform.tfstate:
#
#   aws secretsmanager put-secret-value \
#     --secret-id <name> --secret-string '{"api_key": "sk-ant-..."}'
#
# (There IS an aws_secretsmanager_secret_version resource that sets the value from
# Terraform — know it exists, know why you're not using it here.)
#
# Hint: aws_secretsmanager_secret has a recovery_window_in_days argument.
# Default is 30 days, which means `terraform destroy` only *schedules* deletion
# and the name stays taken for a month. For a learning artifact you may want 0
# (immediate delete). Decide deliberately.
