# TODO: the container registry
# Resource: aws_ecr_repository
# - force_delete = true  (lets `terraform destroy` remove a non-empty repo —
#   same spirit as the bucket's force_destroy in Week 1. Decide deliberately.)
#
# The push flow (this becomes build-push.ps1 / part of deploy):
#   aws ecr get-login-password | docker login --username AWS --password-stdin <acct>.dkr.ecr.<region>.amazonaws.com
#   docker build -t memo-writer ./app
#   docker tag memo-writer:latest <repository_url>:latest
#   docker push <repository_url>:latest
#
# NOTE: pushing :latest and re-deploying is the crude-but-honest loop for this week.
# Real teams tag by git SHA — worth a line in your comparison doc.
