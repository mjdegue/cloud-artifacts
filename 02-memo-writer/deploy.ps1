# Build + deploy the memo-writer Lambda.
# Build phase: vendor deps and code into lambda/package/ (the archive_file source_dir).
# Deploy phase: terraform picks up the changed hash and updates the function.

$ErrorActionPreference = "Stop"
# No Set-Location here: run this from the 02-memo-writer folder. (Also: the user's
# profile shadows Set-Location with a wrapper that breaks argument binding.)
if (-not (Test-Path "lambda/handler.py")) { throw "Run this from the 02-memo-writer folder: cd there, then ./deploy.ps1" }

# Cross-platform vendoring: Lambda runs Linux x86_64, this machine is Windows.
# --platform + --only-binary force pip to fetch Linux wheels instead of local ones.
pip install anthropic -t lambda/package/ --quiet --upgrade `
    --platform manylinux2014_x86_64 --only-binary=:all: --python-version 3.13
Copy-Item lambda/handler.py lambda/package/ -Force

terraform fmt
terraform apply
