output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "resource_group_id" {
  value = azurerm_resource_group.tfstate.id
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "storage_account_id" {
  value = azurerm_storage_account.tfstate.id
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
