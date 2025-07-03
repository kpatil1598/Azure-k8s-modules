terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "terraformtfstate2025"
    container_name       = "terrafom-tfstate-aks"
    key                  = "terraform.tfstate"
    }
}