provider "aws" {
  region = "us-east-1"
}

# Repositório PRIVADO
resource "aws_ecr_repository" "lambda_repo" {
  name                 = "my-lambda-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_url" {
  value = aws_ecr_repository.lambda_repo.repository_url
  description = "URL do repositório para o comando docker push"
}