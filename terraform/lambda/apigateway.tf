module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 5.0" # Garante a versão mais estável

  name          = "my-fastapi-http"
  description   = "API Gateway v2 para FastAPI"
  protocol_type = "HTTP"

  create_api_domain_name = false # Coloque true se tiver um domínio próprio

  # O segredo está aqui: uma única integração para tudo
  integrations = {
    "ANY /{proxy+}" = {
      lambda_arn             = aws_lambda_function.docker_lambda.arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 30000
    }
    "ANY /" = {
      lambda_arn             = aws_lambda_function.docker_lambda.arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 30000
    }
  }

  tags = {
    Environment = "prod"
  }
}

# Permissão para o API Gateway chamar o Lambda (necessário mesmo com módulo)
resource "aws_lambda_permission" "apigw_v2" {
  statement_id  = "AllowExecutionFromAPIGatewayV2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docker_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
}