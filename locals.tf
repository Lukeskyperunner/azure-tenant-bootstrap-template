locals {
  resource_group_name  = "rg-${var.project_name}-tfstate-${var.naming_suffix}"
  storage_account_name = lower(replace("st${var.project_name}tf${var.naming_suffix}", "-", ""))
  container_name       = "tfstate"

  oidc_app_display_name = "github-${var.project_name}-bootstrap-terraform"

  merged_tags = merge(var.tags, {
    project = var.project_name
  })
}
