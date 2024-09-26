resource "aws_s3_object" "job_code" {
  bucket = aws_s3_bucket.working_bucket.id
  key    = "job_vertices/main.zip"
  source = "${path.module}/src/main.py"
  etag   = filemd5("${path.module}/src/main.py")
}

resource "aws_glue_job" "job_vertices" {
  name              = "${local.name_w_mod}-vertices"
  role_arn          = aws_iam_role.example.arn
  max_retries       = 0
  timeout           = 5
  worker_type       = "G.1X"
  number_of_workers = 1
  default_arguments = {
    # ~1 GiB
    "--vertex_file"      = var.s3_vertices
    "--neptune_endpoint" = aws_neptune_cluster_instance.instance.endpoint
  }

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.working_bucket.bucket_regional_domain_name}/${aws_s3_object.job_code.key}"
  }
}
