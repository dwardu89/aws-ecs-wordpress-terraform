locals {
  name        = "wordpress"
  environment = "dev"

  ec2_resources_name = "${local.name}-${local.environment}"
  db_resource_name   = "${local.name}-${local.environment}-db"
  db_user            = "user"
  db_password        = "YouNeedAsecurePassword!"
  db_name            = "wordpress"
}