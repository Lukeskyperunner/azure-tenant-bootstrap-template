data "azurerm_subscription" "current" {}

resource "azuread_application" "this" {
  display_name = var.display_name
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
}

resource "azuread_application_federated_identity_credential" "main_branch" {
  application_id = azuread_application.this.id
  display_name   = "github-main-branch"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_repository}:ref:refs/heads/${var.branch}"
  audiences      = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "owner" {
  scope                = var.resource_group_id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.this.object_id
}

resource "azurerm_role_assignment" "blob" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.this.object_id
}
