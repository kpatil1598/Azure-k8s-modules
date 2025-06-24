output "subscription_id" {
  value = azurerm_subscription.new_sub.subscription_id
}

output "storage_account_name" {
  value = azurerm_storage_account.tf_state.name
}

output "resource_group_name" {
  value = azurerm_resource_group.tf_state.name
}
