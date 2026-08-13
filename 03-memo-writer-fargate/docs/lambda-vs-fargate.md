# Lambda vs. Fargate — the same API, built twice

Artifact 02 and artifact 03 implement the identical memo API. This doc compares
them honestly. **Fill it from your own observations** — this document is
interview material, and "I measured it" beats "the docs say" in every answer.

## Head to head

| Dimension | Lambda (02) | Fargate (03) | Notes from my build |
|---|---|---|---|
| Cold start / first request | | | *(REPORT line Init Duration vs. task startup time)* |
| Latency, warm request | | | |
| Streaming (SSE) | not supported via API GW+Lambda the way you'd want | | *(the deciding factor for LLM UX)* |
| Cost at ~0 traffic | ~$0 | ALB ~$16/mo + task ~$9/mo | *(the deciding factor for hobby scale)* |
| Cost at sustained load | | | *(think: per-request vs per-hour)* |
| Packaging & deploy | zip + --platform pain | Dockerfile | |
| Local dev loop | invoke in cloud / awkward | `uvicorn --reload`, `docker run` | |
| Ops surface | none (no servers, no health checks) | task defs, SGs, target groups, health checks | |
| Timeout ceiling | 15 min hard | none | |
| Scaling model | per-request, automatic | desired_count / autoscaling policies | |

## When I'd pick which

*(2-3 honest paragraphs. Hint: the answer for the Personificator capstone is
Fargate, and the answer for a rarely-used internal webhook is Lambda — argue why.)*

## What surprised me

*(The comparisons nobody writes down: which was more annoying to debug? Which
error messages were better? Where did each one waste an hour?)*
