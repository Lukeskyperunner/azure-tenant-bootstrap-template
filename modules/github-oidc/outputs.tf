output "client_id" {
  value = azuread_application.this.client_id
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "principal_id" {
  value = azuread_service_principal.this.object_id
}
