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
