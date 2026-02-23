terraform {
  backend "s3" {
    bucket         = "my-app-tfstate-2026-xyz"
    key            = "ecr/terraform.tfstate"
    region         = "us-east-1"

    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}