resource "aws_neptune_cluster" "cluster" {
  cluster_identifier                  = local.name_w_mod
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
}
