terraform {
  backend "s3" {
    bucket         = "my-unique-tf-state-bucket-name"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"

    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}