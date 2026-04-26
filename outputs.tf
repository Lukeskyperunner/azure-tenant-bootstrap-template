output "resource_group_name" {
  description = "tfstate resource group name — pass as backend-config when initializing other Terraform configurations"
  value       = module.state_foundation.resource_group_name
}

output "storage_account_name" {
  description = "tfstate storage account name — pass as backend-config when initializing other Terraform configurations"
  value       = module.state_foundation.storage_account_name
}

output "container_name" {
  value = module.state_foundation.container_name
}

output "github_client_id" {
  description = "Set this as GitHub Actions secret AZURE_CLIENT_ID"
  value       = module.github_oidc.client_id
}

output "github_tenant_id" {
  description = "Set this as GitHub Actions secret AZURE_TENANT_ID"
  value       = module.github_oidc.tenant_id
}

output "github_subscription_id" {
  description = "Set this as GitHub Actions secret AZURE_SUBSCRIPTION_ID"
  value       = module.github_oidc.subscription_id
}
