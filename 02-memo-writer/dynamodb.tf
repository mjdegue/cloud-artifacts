# TODO: the memos table
# Resource type: aws_dynamodb_table
# Requirements:
# - billing_mode: PAY_PER_REQUEST (on-demand — no capacity planning, pennies at your scale)
# - hash_key (partition key): the memo id, type String
#   NOTE: only declare `attribute` blocks for keys/indexes — DynamoDB is schemaless
#   for everything else. Declaring non-key attributes here is an error.
# - ttl block: enable TTL on an attribute (e.g. "expires_at").
#   The value your Lambda writes there must be a UNIX EPOCH TIMESTAMP (seconds) —
#   DynamoDB deletes items (lazily, within ~48h) after that time passes.
#
# Verify after apply:
#   aws dynamodb put-item --table-name <name> --item '{"id": {"S": "test-1"}}'
#   aws dynamodb get-item --table-name <name> --key '{"id": {"S": "test-1"}}'

resource "aws_dynamodb_table" "memos" {
  name         = "memos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
}
