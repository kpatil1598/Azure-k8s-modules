# Create Storage Account for state
resource "azurerm_storage_account" "tf_state" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.tf_state.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  provider                 = azurerm.newsub
}

# Create Blob Container for Terraform state
resource "azurerm_storage_container" "tfstate" {
  name                  = var.storage_container_name
  storage_account_id  = azurerm_storage_account.tf_state.id
  container_access_type = "private"
  provider              = azurerm.newsub
}