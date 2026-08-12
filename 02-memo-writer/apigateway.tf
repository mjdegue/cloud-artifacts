# TODO: HTTP API in front of the Lambda — four resources + one permission
#
# 1. aws_apigatewayv2_api        — protocol_type "HTTP" (the cheap, simple kind)
# 2. aws_apigatewayv2_integration — connects the API to the Lambda
#    (integration_type "AWS_PROXY", payload_format_version "2.0")
# 3. aws_apigatewayv2_route      — two of these:
#      route_key "POST /memo"  and  "GET /memo/{id}"
#    (the {id} becomes event.pathParameters.id in your handler)
# 4. aws_apigatewayv2_stage      — name "$default", auto_deploy true
#
# 5. aws_lambda_permission — THE ONE PEOPLE FORGET.
#    API Gateway needs permission to invoke your function. This is a
#    RESOURCE-BASED policy on the Lambda (principal: apigateway.amazonaws.com)
#    — the same policy type as your Week 1 bucket policy, attached to a
#    function instead of a bucket. Without it: the API returns 500s while
#    your Lambda logs show nothing at all, because it was never invoked.
#    You may choose to discover this empirically first. It builds character.
