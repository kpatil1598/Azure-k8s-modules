provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "afd-signedurl-rg"
  location = "eastus"
}

module "afd_signedurl" {
  source              = "../../modules/afd_signedurl"
  prefix              = "afdsgn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

# outputs
output "frontdoor_endpoint" {
  value = module.afd_signedurl.frontdoor_endpoint
}
output "signing_secret" {
  value     = module.afd_signedurl.signing_secret
  sensitive = true
}
