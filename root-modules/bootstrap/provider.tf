# Configure provider for the new subscription
provider "azurerm" {
  alias           = "newsub"
  features{}
  subscription_id = module.subscription.subscription_id
}
  
