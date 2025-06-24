provider "azurerm" {
  alias    = "management"
  features {}
}

# Get MCA Billing Scope
data "azurerm_billing_mca_account_scope" "billing" {
  billing_account_name  = var.billing_account_name
  billing_profile_name  = var.billing_profile_name
  invoice_section_name  = var.invoice_section_name
}

# Create the Subscription
resource "azurerm_subscription" "new_sub" {
  subscription_name = var.subscription_name
  billing_scope_id  = data.azurerm_billing_mca_account_scope.billing.id
}

# Configure provider for the new subscription
provider "azurerm" {
  alias           = "newsub"
  features{}
  subscription_id = azurerm_subscription.new_sub.subscription_id
}

# Create Resource Group for backend storage
resource "azurerm_resource_group" "tf_state" {
  name     = var.resource_group_name
  location = var.location
  provider = azurerm.newsub
}

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
