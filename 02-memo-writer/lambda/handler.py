"""AI Memo Writer — Lambda handler.

POST /memo      {topic, audience, length} -> generate memo, store, return {id, memo}
GET  /memo/{id}                           -> fetch a stored memo

Skeleton with TODOs — the structure is given, the implementations are yours.
Work with the docs open:
  - anthropic SDK: https://github.com/anthropics/anthropic-sdk-python
  - boto3 dynamodb/secretsmanager: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html
"""
# TODO: imports you'll need — boto3, anthropic, uuid, time

import json
import logging
import os
import time
import uuid

import boto3
from anthropic import Anthropic

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

TABLE_NAME = os.environ["TABLE_NAME"]  # set via Terraform env vars
SECRET_NAME = os.environ["SECRET_NAME"]

MODEL = "claude-haiku-4-5"  # cheap + fast; a memo costs a fraction of a cent

SECRET_CLIENT = boto3.client("secretsmanager")
# NOTE: the secret is stored as the bare API key, not JSON — parsing must match storage
ANTHROPIC_API_KEY = SECRET_CLIENT.get_secret_value(SecretId=SECRET_NAME)["SecretString"]
ANTHROPIC_CLIENT = Anthropic(api_key=ANTHROPIC_API_KEY)

DB_CLIENT = boto3.client("dynamodb")


def handler(event, context):
    """Entry point. `event` is API Gateway's HTTP API v2.0 payload.

    Useful fields:
      event["requestContext"]["http"]["method"]  -> "POST" / "GET"
      event["body"]                              -> JSON string (POST)
      event["pathParameters"]["id"]              -> the {id} from the route (GET)
    Log the whole event once while developing: logger.info(json.dumps(event))
    """

    try:
        match event["requestContext"]["http"]["method"]:
            case "POST":
                return _create_memo(event)
            case "GET":
                return _get_memo(event)
            case "DELETE":
                return _delete_memo(event)
            case _:
                return _response(405, {"error": "method not allowed"})
    except Exception:
        logger.exception("Unhandled exception")
        return _response(500, {"error": "Internal server error"})


def _create_memo(event):

    try:
        parsed_body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"error": "body must be valid JSON"})

    topic = parsed_body.get("topic")
    audience = parsed_body.get("audience")
    try:
        length = int(parsed_body.get("length"))
    except (TypeError, ValueError):
        length = None

    if topic is None or audience is None or length is None:
        return _response(
            422, {"error": "topic, audience and numeric length are required"}
        )

    if length > 400:
        return _response(422, {"error": "Length is 400 as maximum"})

    answer = ANTHROPIC_CLIENT.messages.create(
        model=MODEL,
        max_tokens=512,
        system="You write crisp professional memos about incoming secified topics for audiences and specified length. Output only the memo text, no preamble. Also, there should be no item or information I should fill up myself such as time/date/etc",
        messages=[
            {
                "role": "user",
                "content": f"topic: {topic} audience: {audience} length: {length}",
            }
        ],
    )

    # TODO 3: build the item: id (uuid), topic/audience/length, the memo,
    #         created_at, and expires_at = now + N days AS EPOCH SECONDS
    #         (must match the TTL attribute name in your table!)

    generated_id = str(uuid.uuid4())
    generated_memo = answer.content[0].text

    now = int(time.time())
    table_item = {
        "id": {"S": generated_id},
        "memo": {"S": generated_memo},
        "created_at": {
            "N": str(now),
        },
        "expires_at": {
            "N": str(now + 1 * 86400),
        },
    }

    # TODO 4: put_item, then return _response(200, {"id": ..., "memo": ...})

    put_item_response = DB_CLIENT.put_item(TableName=TABLE_NAME, Item=table_item)
    logger.info(put_item_response)

    return _response(200, {"id": generated_id, "memo": generated_memo})


def _get_memo(event):
    # TODO: read the id from pathParameters, get_item from DynamoDB,
    #       404 if missing, else return the memo
    get_item_response = DB_CLIENT.get_item(
        TableName=TABLE_NAME, Key={"id": {"S": event["pathParameters"]["id"]}}
    )

    item = get_item_response.get("Item")
    if item is None:
        return _response(404, "Item not found")

    answer_object = {
        "id": item["id"]["S"],
        "memo": item["memo"]["S"],
    }
    return _response(200, answer_object)


def _delete_memo(event):
    # TODO: extra, delete memo
    id_for_delete = event["pathParameters"]["id"]
    delete_item_response = DB_CLIENT.delete_item(
        TableName=TABLE_NAME, Key={"id": {"S": id_for_delete}}, ReturnValues="ALL_OLD"
    )
    old_item = delete_item_response.get("Attributes")
    if old_item is None:
        return _response(404, "Item not found")

    return _response(200, {"deleted": id_for_delete})


def _response(status, body):
    """API Gateway HTTP API expects this exact shape."""
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
