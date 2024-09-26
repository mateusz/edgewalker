provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "edgewalker-dev-state-storage-us-east-1"
    region         = "us-east-1"
    key            = "edgewalker-dev-us-east-1.tfstate"
    dynamodb_table = "edgewalker-dev-state-lock-us-east-1"
  }
}

resource "aws_s3_bucket" "terraform_state_storage" {
  bucket = "edgewalker-dev-state-storage-us-east-1"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_storage" {
  bucket = aws_s3_bucket.terraform_state_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_storage" {
  bucket = aws_s3_bucket.terraform_state_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "edgewalker-dev-state-lock-us-east-1"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1
  attribute {
    name = "LockID"
    type = "S"
  }
}
