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

# TODO add a stopped notebook instance for graph viz
