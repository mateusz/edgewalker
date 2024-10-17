# TODO add networking

resource "aws_neptune_cluster" "cluster" {
  cluster_identifier                  = replace(local.name_w_mod, "_", "-")
  engine                              = "neptune"
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = true
  apply_immediately                   = true
  tags                                = local.base_tags
}

resource "aws_neptune_cluster_instance" "instance" {
  cluster_identifier = aws_neptune_cluster.cluster.id
  engine             = "neptune"
  instance_class     = "db.t3.medium"
  apply_immediately  = true
  tags               = local.base_tags_with_name_w_mod
}

resource "aws_glue_connection" "neptune_glue" {
  name            = "${local.name_w_mod}-neptune"
  connection_type = "NETWORK"
  physical_connection_requirements {
    availability_zone      = "us-east-1f"
    security_group_id_list = ["sg-0f14b288b788e14d0"]
    subnet_id              = "subnet-033fcef70d96227ea"
  }
  tags = local.base_tags
}
# TODO add a stopped notebook instance for graph viz
