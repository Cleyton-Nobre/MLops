resource "aws_apigatewayv2_api" "http_api" {
  name          = "lambda-http-api"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "apí_gateway" {
  statement_id = "AllowAPIGatewayInvoke"
  action    = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docker_lambda.function_name
  principal ="apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.docker_lambda.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}