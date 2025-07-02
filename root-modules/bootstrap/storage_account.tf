# Create Storage Account for state
resource "azurerm_storage_account" "tf_state" {
  name                     = "${var.account_code}tfstate32344"
  resource_group_name      = azurerm_resource_group.tf_state.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  provider                 = azurerm.newsub
}

# Create Blob Container for Terraform state
resource "azurerm_storage_container" "tfstate" {
  name                  = "${var.account_code}"
  storage_account_name  = azurerm_storage_account.tf_state.name
  container_access_type = "private"
  provider              = azurerm.newsub
}