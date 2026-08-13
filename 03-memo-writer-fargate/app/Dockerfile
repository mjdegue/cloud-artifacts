# TODO: write this — it's 6 instructions, and it PERMANENTLY solves Week 2's
# packaging pain (pip runs INSIDE Linux; no --platform flags ever again).
#
# The instructions you need, in order:
#   FROM     python:3.13-slim        (match the runtime you know; slim = smaller image)
#   WORKDIR  /app
#   COPY     requirements.txt .      <- requirements FIRST, alone. See below.
#   RUN      pip install --no-cache-dir -r requirements.txt
#   COPY     . .
#   CMD      ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
#            (0.0.0.0 not 127.0.0.1 — inside a container, localhost is a wall)
#
# WHY requirements before code — THE LAYER CACHING LESSON:
# each instruction creates a cached layer, invalidated only if its inputs change.
# Code changes daily; dependencies change monthly. Copy requirements first and
# `docker build` after a code edit reuses the pip layer: seconds, not minutes.
# This is the same prefix-invalidation idea as Terraform plan diffs — order by
# volatility.
#
# Local test loop before any AWS:
#   docker build -t memo-writer .
#   docker run -p 8080:8080 -e TABLE_NAME=memos -e SECRET_NAME=... \
#     -e AWS_ACCESS_KEY_ID=... -e AWS_SECRET_ACCESS_KEY=... memo-writer
#   (or mount your ~/.aws — the container has no credentials of its own locally;
#    on Fargate the task role provides them, like the Lambda role did)
