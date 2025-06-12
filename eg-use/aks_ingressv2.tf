# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 3.0"
#     }
#     helm = {
#       source  = "hashicorp/helm"
#       version = "~> 2.0"
#     }
#   }

#   required_version = ">= 1.0.0"
# }

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = ""
  }
}

data "azurerm_client_config" "current" {}

# data "azurerm_kubernetes_cluster" "aks" {
#   name                = "aks-cluster"
#   resource_group_name = "rg-aks"
# }

# module "app_gateway" {
#   source              = "../modules/app_gateway"
#   name                = "agic-appgw"
#   location            = "eastus"
#   resource_group_name = module.resource_group.resource_group_name
#   subnet_id           = values(module.networking.public_subnet_ids)[0] # Adjust based on your vnet module output
#   is_public           = true
#   #min_capacity        = 2
#   #max_capacity        = 5

#   tags = {
#     environment = "dev"
#     project     = "aks-ingress"
#   }
# }

# module "agic_identity" {
#   source              = "../modules/agic_identity"
#   name                = "agic-identity"
#   location            = "eastus"
#   resource_group_name = module.resource_group.resource_group_name
#   appgw_id            = module.app_gateway.id
#   appgw_rg_scope      = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg-aks-dev"
# }

module "agic_helm" {
  source               = "../modules/agic_helm"
    location             = "eastus"
    resource_group_name  = module.resource_group.resource_group_name 
}
