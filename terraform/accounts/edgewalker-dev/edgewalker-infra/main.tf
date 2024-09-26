module "neptune" {
  source      = "../../../modules/ew_graph"
  account     = "edgewalker-dev"
  stack       = "ewtest"
  environment = "dev"
}
