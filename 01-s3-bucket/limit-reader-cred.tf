
resource "aws_iam_user" "limit_reader" {
  name = "limit_reader"
}

resource "aws_iam_user_policy_attachment" "limit_reader_attachment" {
  user       = aws_iam_user.limit_reader.name
  policy_arn = aws_iam_policy.limit_reader_policy.arn
}

resource "aws_iam_policy" "limit_reader_policy" {
  name   = "ReadOnlyPolicy"
  policy = data.aws_iam_policy_document.limit_reader_doc.json
}

data "aws_iam_policy_document" "limit_reader_doc" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.this.arn}"]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["Resources/*"]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/Resources/*"]
  }
}
