terraform {
  backend "s3" {
    bucket         = "my-app-tfstate-2026-xyz"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"

    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}