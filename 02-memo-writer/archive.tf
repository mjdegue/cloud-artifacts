data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/package/"
  output_path = "${path.module}/lambda.zip"
  excludes    = ["__pycache__", "**/__pycache__"]
}
