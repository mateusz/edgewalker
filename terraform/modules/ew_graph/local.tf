locals {
  name       = "${var.stack}-${var.environment}"
  name_w_mod = "ew_graph-${var.stack}-${var.environment}"
  base_tags = merge(var.tags, {
    "ss:module"      = "log_monitor"
    "ss:stack"       = var.stack
    "ss:environment" = var.environment
    "ss:name"        = local.name
  })
  base_tags_with_name = merge(local.base_tags, {
    Name = local.name
  })
  base_tags_with_name_w_mod = merge(local.base_tags, {
    Name = local.name_w_mod
  })
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
