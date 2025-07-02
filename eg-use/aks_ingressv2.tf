# # terraform {
# #   required_providers {
# #     azurerm = {
# #       source  = "hashicorp/azurerm"
# #       version = "~> 3.0"
# #     }
# #     helm = {
# #       source  = "hashicorp/helm"
# #       version = "~> 2.0"
# #     }
# #   }

# #   required_version = ">= 1.0.0"
# # }

# provider "helm" {
#   kubernetes {
#     config_path    = "~/.kube/config"
#     config_context = ""
#   }
# }

# data "azurerm_client_config" "current" {}


# module "agic_helm" {
#   source               = "C:\\Users\\chava\\Desktop\\k8s-module\\modules\\agic_helm"
#     location             = "eastus"
#     resource_group_name  = module.resource_group.resource_group_name 
# }
