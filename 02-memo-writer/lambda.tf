# ---------------------------------------------------------------------------
# TODO 1: the Lambda's execution role
# Resource type: aws_iam_role
# - Its assume_role_policy is a trust policy: WHO may assume this role.
#   Here the principal is not a user or account — it's an AWS SERVICE
#   (lambda.amazonaws.com), action "sts:AssumeRole".
#   This is the assume-role concept from your IAM reading, finally in the wild:
#   the Lambda service assumes this role and your code inherits its permissions.
#   No access keys anywhere — compare with how YOU authenticate.

resource "aws_iam_role" "memo_writer" {
  name               = "memo-writer-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
  description        = "Role used by the memo writer lambda to access the database."
}

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------
# TODO 2: least-privilege permissions for that role
# Resource type: aws_iam_role_policy (inline) + data.aws_iam_policy_document
# Exactly three capabilities, nothing more (Build-4 skills, applied to a role):
# - read THE ONE secret        (secretsmanager:GetSecretValue on its ARN)
# - read/write THE ONE table   (dynamodb:PutItem, GetItem on its ARN)
# - write its own logs         (logs:CreateLogGroup, CreateLogStream, PutLogEvents)
#   For log ARNs, "arn:aws:logs:*" is acceptable for now; tightening it is a bonus.
# Reference the secret and table ARNs from your other .tf files — same cross-
# resource reference pattern as Week 1, now across files (same directory, same
# state — files are just organization).

resource "aws_iam_role_policy" "memo_writer_permissions" {
  policy = data.aws_iam_policy_document.memo_writer_permissions.json
  role   = aws_iam_role.memo_writer.id
}

data "aws_iam_policy_document" "memo_writer_permissions" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.anthropic_key.arn]
  }

  statement {
    actions   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem"]
    resources = [aws_dynamodb_table.memos.arn]
  }

  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*"]
  }

}

# ---------------------------------------------------------------------------
# TODO 3: package the code — THE LAMBDA PACKAGING LESSON
# AWS provides only the Python stdlib + boto3 in the runtime. The `anthropic`
# SDK must ship inside your zip. The workflow:
#
#   cd lambda
#   pip install anthropic -t package/     # vendors deps into package/
#   copy handler.py into package/         # code + deps side by side
#
# then zip it. Options (pick one):
#   a) data "archive_file" — zips a directory at plan time (needs the archive
#      provider; see versions.tf)
#   b) build.ps1 / Makefile that produces lambda.zip, referenced by filename
# Either way aws_lambda_function needs `filename` + `source_code_hash` so
# Terraform knows when the code changed. (Real teams use CI or containers for
# this; a local script is honest for now.)

resource "aws_lambda_function" "memo_writer" {
  role             = aws_iam_role.memo_writer.arn
  function_name    = "memo-writer"
  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  runtime          = "python3.13"
  handler          = "handler.handler"
  timeout          = 60
  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.memos.name
      SECRET_NAME = aws_secretsmanager_secret.anthropic_key.name
    }
  }
}

# ---------------------------------------------------------------------------
# TODO 4: the function itself
# Resource type: aws_lambda_function
# - runtime "python3.13", handler "handler.handler" (file.function)
# - role: the role's ARN from TODO 1
# - timeout: DEFAULT IS 3 SECONDS — a Claude call will blow through that.
#   Set ~30-60s. You WILL hit this if you forget; remember this comment.
# - environment variables: pass the table name and secret name so handler.py
#   doesn't hardcode them (env { variables = { ... } })
