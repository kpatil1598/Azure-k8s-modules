# Create Resource Group for backend storage
resource "azurerm_resource_group" "tf_state" {
  name     = var.resource_group_name
  location = var.location
  provider = azurerm.newsub
}


