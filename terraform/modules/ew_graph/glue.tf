resource "aws_s3_bucket" "working_bucket" {
  bucket = replace("${var.account}-${local.name_w_mod}-working", "_", "-")
  lifecycle {
    prevent_destroy = false
  }
  tags = local.base_tags
}

resource "aws_s3_bucket_public_access_block" "working_bucket" {
  bucket = aws_s3_bucket.working_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
