resource "aws_s3_object" "job_code" {
  bucket = aws_s3_bucket.working_bucket.id
  key    = "job_vertices/main.zip"
  source = "${path.module}/src/main.py"
  etag   = filemd5("${path.module}/src/main.py")
  tags   = local.base_tags
}

resource "aws_iam_role" "job_vertices_role" {
  name = "${local.name_w_mod}-job_vertices"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })

  tags = local.base_tags
}

resource "aws_glue_job" "job_vertices" {
  name              = "${local.name_w_mod}-vertices"
  role_arn          = aws_iam_role.job_vertices_role.arn
  max_retries       = 0
  timeout           = 5
  worker_type       = "G.1X"
  number_of_workers = 2
  default_arguments = {
    # ~1 GiB
    "--vertex_file"      = var.s3_vertices
    "--neptune_endpoint" = aws_neptune_cluster_instance.instance.endpoint
  }

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.working_bucket.bucket}/${aws_s3_object.job_code.key}"
    python_version  = "3"
  }

  tags = local.base_tags
}
