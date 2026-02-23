# 1. Cria a API HTTP (v2)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "fastapi-http-api"
  protocol_type = "HTTP"
}

# 2. Cria o Stage (O $default faz com que não precise de /prod na URL)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name  = "prod"
  auto_deploy = true
}

# 3. Integração Única com o Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  integration_uri    = aws_lambda_function.docker_lambda.invoke_arn
  payload_format_version = "2.0"
}

# 4. Rota "Catch-all" (Qualquer método, qualquer caminho)
resource "aws_apigatewayv2_route" "catch_all" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 5. Rota para a Raiz (/)
resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 6. Permissão para o Gateway chamar o Lambda
resource "aws_lambda_permission" "apigw_v2" {
  statement_id  = "AllowExecutionFromAPIGatewayV2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docker_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# Output para facilitar sua vida
output "api_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}