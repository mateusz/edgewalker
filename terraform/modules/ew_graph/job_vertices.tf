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

resource "aws_iam_policy" "job_vertices_policy" {
  name = "${local.name_w_mod}-job_vertices"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:List*",
          "s3:Get*"
        ],
        "Resource" : [
          "arn:aws:s3:::commoncrawl",
          "arn:aws:s3:::commoncrawl/*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:List*",
          "s3:Get*",
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:PutObject",
        ],
        "Resource" : [
          "arn:aws:s3:::edgewalker-dev-ew-graph-ewtest-dev-working",
          "arn:aws:s3:::edgewalker-dev-ew-graph-ewtest-dev-working/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:PutMetricData",
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:*"
        ]
      },
      {
        "Action" : "neptune-db:connect",
        "Resource" : "arn:aws:neptune-db:eu-east-1:400678530796:*/*",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "glue:GetConnection",
        ],
        "Resource" : [
          "arn:aws:glue:us-east-1:400678530796:catalog",
          "arn:aws:glue:us-east-1:400678530796:connection/ew_graph-ewtest-dev-neptune"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeRouteTables",
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:CreateTags",
        ],
        "Resource" : [
          #"arn:aws:ec2:us-east-1:400678530796:vpc/vpc-01aeb2df438ef0bbb"
          "*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "job_vertices_policy_attachment" {
  role       = aws_iam_role.job_vertices_role.name
  policy_arn = aws_iam_policy.job_vertices_policy.arn
}

resource "aws_cloudwatch_log_group" "job_vertices" {
  name              = "${local.name_w_mod}-job_vertices"
  retention_in_days = 1
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
    "--vertex_file"                      = var.s3_vertices
    "--neptune_endpoint"                 = aws_neptune_cluster_instance.instance.endpoint
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.job_vertices.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
  }

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.working_bucket.bucket}/${aws_s3_object.job_code.key}"
    python_version  = "3"
  }

  tags = local.base_tags
}
