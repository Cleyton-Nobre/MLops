provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "ecr_info" {
  backend = "s3"
  config = {
    bucket = "my-app-tfstate-2026-xyz"
    key    = "ecr/terraform.tfstate" # Onde o estado do ECR foi salvo
    region = "us-east-1"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_ecr_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "lambda_custom_metrics" {
  name = "lambda-custom-metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_custom_metrics" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_custom_metrics.arn
}

# Permissões básicas (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# A Lambda Function
# IMPORTANTE: Se o ECR e a Lambda estiverem no mesmo projeto Terraform, 
# a referência abaixo funciona. Se forem projetos separados, use uma variável para o image_uri.
resource "aws_lambda_function" "docker_lambda" {
  function_name = "my-docker-lambda"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  
  # Referenciando o repositório do outro arquivo
  image_uri = "${data.terraform_remote_state.ecr_info.outputs.repository_url}:latest"

  timeout     = 30
  memory_size = 512

  depends_on = [aws_iam_role_policy_attachment.lambda_logs, aws_iam_role_policy_attachment.attach_custom_metrics]
}