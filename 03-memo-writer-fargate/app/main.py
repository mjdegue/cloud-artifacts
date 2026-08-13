"""AI Memo Writer v2 — FastAPI on Fargate.

Same API as Week 2, plus streaming:
  GET    /health            -> ALB health check (implemented — it's infrastructure)
  POST   /memo              -> generate, store, return {id, memo}
  GET    /memo/{memo_id}    -> fetch
  DELETE /memo/{memo_id}    -> delete
  POST   /memo/stream       -> generate with STREAMING response (SSE) — the
                               week's centerpiece, and the reason Fargate exists
                               in this course.

This is mostly a PORT of your Week 2 handler.py — the business logic transfers
almost line for line. What's new: FastAPI's routing/validation replaces your
hand-rolled match/parse/validate, and streaming replaces one blocking call.
FastAPI docs: https://fastapi.tiangolo.com/tutorial/
"""

import logging
import os

import boto3
from anthropic import Anthropic
from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

logger = logging.getLogger("memo-writer")
logging.basicConfig(level=logging.INFO)  # TODO (stretch): structured JSON logs —
# a formatter that emits {"level": ..., "msg": ..., "path": ...} makes the
# CloudWatch Logs Insights success criterion much easier. Plain logs OK to start.

TABLE_NAME = os.environ["TABLE_NAME"]
SECRET_NAME = os.environ["SECRET_NAME"]
MODEL = "claude-haiku-4-5"

# Module scope = process scope here (the container runs ONE long-lived process
# serving many requests — contrast with Lambda's per-container init):
# TODO: boto3 client(s), secret fetch, Anthropic client — port from Week 2.

app = FastAPI(title="AI Memo Writer v2")


class MemoRequest(BaseModel):
    """FastAPI + pydantic replace your hand-rolled validation: a body that
    doesn't match this model is rejected with a 422 BEFORE your code runs.
    Delete-your-own-code upgrade — enjoy it.
    """

    topic: str
    audience: str
    length: int  # TODO: enforce the <= 400 cap here (pydantic Field(le=400))


@app.get("/health")
def health():
    # The ALB polls this. Keep it dumb and fast — no dependencies, no DB calls.
    return {"status": "ok"}


@app.post("/memo")
def create_memo(req: MemoRequest):
    # TODO: port _create_memo — Claude call, uuid, timestamps, put_item.
    # Differences from Lambda:
    # - req.topic / req.audience / req.length are already validated & typed
    # - return a plain dict -> FastAPI serializes it; no _response() helper
    # - errors: raise HTTPException(status_code=..., detail=...) instead of
    #   returning a response object
    raise NotImplementedError


@app.get("/memo/{memo_id}")
def get_memo(memo_id: str):
    # TODO: port _get_memo. The path parameter arrives as the typed argument —
    # no event dict spelunking. 404: raise HTTPException(404, "memo not found").
    raise NotImplementedError


@app.delete("/memo/{memo_id}")
def delete_memo(memo_id: str):
    # TODO: port _delete_memo (keep ReturnValues="ALL_OLD" + the 404 distinction).
    raise NotImplementedError


@app.post("/memo/stream")
def create_memo_stream(req: MemoRequest):
    # THE NEW THING. Instead of waiting ~5s and returning the whole memo,
    # stream tokens to the client as Claude produces them.
    #
    # Shape:
    #   def event_stream():                       # a generator function
    #       with ANTHROPIC_CLIENT.messages.stream(...) as stream:
    #           for text in stream.text_stream:   # chunks as they arrive
    #               yield f"data: {json.dumps(text)}\n\n"   # SSE wire format
    #       # after the loop: stream.get_final_message() has the full text +
    #       # stop_reason -> persist to DynamoDB here, yield a final event
    #       # with the memo id so the client can fetch/delete it later.
    #   return StreamingResponse(event_stream(), media_type="text/event-stream")
    #
    # SSE format rules: each event is "data: <payload>\n\n" (the blank line
    # terminates the event). json.dumps the chunk so newlines inside the text
    # don't break the framing.
    #
    # Test with: curl -N http://<alb>/memo/stream ... (-N disables buffering —
    # you'll SEE tokens arrive. That moment is the week's payoff.)
    raise NotImplementedError


# Local dev (no Docker, no AWS ingress):
#   uvicorn main:app --reload --port 8080
# Run this loop on your machine FIRST — deploy to Fargate only when the app
# works locally. Containers change where code runs, not how you develop it.
