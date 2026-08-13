"""AI Memo Writer — Lambda handler.

POST /memo      {topic, audience, length} -> generate memo, store, return {id, memo}
GET  /memo/{id}                           -> fetch a stored memo

Skeleton with TODOs — the structure is given, the implementations are yours.
Work with the docs open:
  - anthropic SDK: https://github.com/anthropics/anthropic-sdk-python
  - boto3 dynamodb/secretsmanager: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html
"""

import json
import logging
import os

# TODO: imports you'll need — boto3, anthropic, uuid, time

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

TABLE_NAME = os.environ["TABLE_NAME"]  # set via Terraform env vars
SECRET_NAME = os.environ["SECRET_NAME"]

MODEL = "claude-haiku-4-5"  # cheap + fast; a memo costs a fraction of a cent

# COLD START LESSON: module scope runs once per container, then is reused across
# invocations. Expensive setup belongs HERE, not inside handler():
# TODO: create boto3 clients here
# TODO: fetch the secret here, create the Anthropic client here
#   (fetching the secret once per container instead of once per request is the
#    difference between one Secrets Manager call and thousands)


def handler(event, context):
    """Entry point. `event` is API Gateway's HTTP API v2.0 payload.

    Useful fields:
      event["requestContext"]["http"]["method"]  -> "POST" / "GET"
      event["body"]                              -> JSON string (POST)
      event["pathParameters"]["id"]              -> the {id} from the route (GET)
    Log the whole event once while developing: logger.info(json.dumps(event))
    """
    # TODO: route on the HTTP method -> _create_memo(event) or _get_memo(event)
    # TODO: wrap in try/except; on failure log with logger.exception(...) and
    #       return a 500 WITHOUT leaking internals to the caller. The traceback
    #       goes to CloudWatch (your Week 1 logging lesson, now load-bearing —
    #       this is exactly what you'll read when you break it on purpose).

    try:
        match event["requestContext"]["http"]["method"]:
            case "POST":
                return _create_memo(event)
            case "GET":
                return _get_memo(event)
            case _:
                return _response(405, {"error": "method not allowed"})
    except Exception:
        logger.exception("Unhandled exception")
        return _response(500, {"Ok": False})


def _create_memo(event):
    # TODO 1: parse + validate the body: topic (required), audience, length
    #         -> 400 with a helpful message if invalid
    # TODO 2: call Claude. client.messages.create(model=MODEL, max_tokens=...,
    #         system=..., messages=[{"role": "user", "content": ...}])
    #         Write the system prompt yourself: what makes a good memo?
    #         Response text lives in the content BLOCKS: pick the "text" block.
    # TODO 3: build the item: id (uuid), topic/audience/length, the memo,
    #         created_at, and expires_at = now + N days AS EPOCH SECONDS
    #         (must match the TTL attribute name in your table!)
    # TODO 4: put_item, then return _response(200, {"id": ..., "memo": ...})
    raise NotImplementedError


def _get_memo(event):
    # TODO: read the id from pathParameters, get_item from DynamoDB,
    #       404 if missing, else return the memo
    raise NotImplementedError


def _response(status, body):
    """API Gateway HTTP API expects this exact shape."""
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
