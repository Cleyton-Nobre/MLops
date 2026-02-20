provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Repositório PRIVADO (O Lambda exige este tipo)
resource "aws_ecr_repository" "lambda_repo" {
  name                 = "my-lambda-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
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

# Attach basic execution rights
# Permite logs (o que você já tem)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permite que o Lambda baixe a imagem do ECR (O que está faltando!)
resource "aws_iam_role_policy_attachment" "lambda_ecr" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


# The Lambda Function
resource "aws_lambda_function" "docker_lambda" {
  function_name = "my-docker-lambda"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  
  # Agora referenciando o repositório privado
  image_uri = "${aws_ecr_repository.lambda_repo.repository_url}:latest"

  timeout     = 30
  memory_size = 512
}