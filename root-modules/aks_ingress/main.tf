# App Gateway (Module 1)
module "app_gateway" {
  source              = "../modules/app_gateway"
  name                = "agic-appgw"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.appgw_subnet_id
  is_public           = true

  min_capacity        = 2
  max_capacity        = 5
  tags                = var.tags
}

# AGIC Managed Identity (Module 2)
module "agic_identity" {
  source             = "../modules/agic_identity"
  name               = "agic"
  location           = var.location
  resource_group_name = var.rg_name
  appgw_id           = module.app_gateway.id
  appgw_rg_scope     = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.rg_name}"
}

# AGIC Helm deployment (Module 3)
module "agic_helm" {
  source                = "../modules/agic_helm"
  appgw_name            = module.app_gateway.name
  appgw_rg              = module.app_gateway.resource_group_name
  subscription_id       = data.azurerm_client_config.current.subscription_id
  identity_client_id    = module.agic_identity.client_id
  identity_resource_id  = module.agic_identity.resource_id
  chart_version         = "1.7.1"
}