# TODO: output the API's invoke URL (the stage's invoke_url or api_endpoint)
# so you can:  curl "$(tf output -raw api_url)/memo" ...
# Bonus outputs: table name, secret name — handy for CLI verification.
output "memo_api_url" {
  value = aws_apigatewayv2_api.memo_api.api_endpoint
}

output "memo_table_name" {
  value = aws_dynamodb_table.memos.name
}

output "memo_secret_name" {
  value = aws_secretsmanager_secret.anthropic_key.name
}
