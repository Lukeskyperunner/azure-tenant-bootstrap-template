module "state_foundation" {
  source = "./modules/state-foundation"

  resource_group_name  = local.resource_group_name
  storage_account_name = local.storage_account_name
  container_name       = local.container_name
  location             = var.location
  tags                 = local.merged_tags
}

module "github_oidc" {
  source = "./modules/github-oidc"

  display_name       = local.oidc_app_display_name
  github_repository  = var.github_repository
  resource_group_id  = module.state_foundation.resource_group_id
  storage_account_id = module.state_foundation.storage_account_id
}
