resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "vpc-01aeb2df438ef0bbb"
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = ["rtb-04af2b069cc56f67f"]
  tags            = local.base_tags_with_name_w_mod
}
