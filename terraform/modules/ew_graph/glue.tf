resource "aws_s3_bucket" "working_bucket" {
  bucket = "${var.account}-${local.name_w_mod}-working"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_storage" {
  bucket = aws_s3_bucket.working_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_storage" {
  bucket = aws_s3_bucket.working_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
