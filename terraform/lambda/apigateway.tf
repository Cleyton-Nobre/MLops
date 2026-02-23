module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws" # Exemplo para HTTP API, mais simples e barato
  name    = "my-fastapi"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_origins = ["*"]
  }

  # Integração direta com o Lambda
  integrations = {
    "ANY /{proxy+}" = {
      lambda_arn             = aws_lambda_function.docker_lambda.arn
      payload_format_version = "2.0"
    }
    "ANY /" = {
      lambda_arn             = aws_lambda_function.docker_lambda.arn
      payload_format_version = "2.0"
    }
  }
}