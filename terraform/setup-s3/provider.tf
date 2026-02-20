provider "aws" {
  region = "us-east-1"
}


# The S3 Bucket for State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-app-tfstate-2026-xyz" # Change this!

  # prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning so you can roll back state if needed
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}