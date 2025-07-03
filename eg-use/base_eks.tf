# module "network" {
#   source = "..\\modules\\dynamic-subnet-dual-stack"
#   # ... pass vnet_name, subnet_name, etc.
# }

module "aks" {
  source              = "..\\root-modules\\base_aks"
  resource_group_name = module.resource_group.resource_group_name
  location            = "eastus"
  cluster_name        = "aks-cluster"
  dns_prefix          = "akscluster"
  kubernetes_version  = "1.31"
  vnet_subnet_id      = values(module.networking.private_subnet_ids)[0] # Adjust based on your vnet module output
  #gateway_id         = module.app_gateway.id
  #ats_node_pool_enabled = true

}

#     nodepools = {
#        ats_nodegroup = {
#         name                  = "atsnodegroup"
#         vm_size               = "Standard_B2s"
#         min_count             = 1
#         max_count             = 2
#         node_count           = 1
#         enable_auto_scaling   = true
#         upgrade_settings      = {
#           max_surge = "1" # Minimal surge capacity during upgrades
#         }
#         enable_auto_scaling   = true
#         vnet_subnet_id        = values(module.networking.private_subnet_ids)[0]
#         enable_node_public_ip = false
#        # zones                 = [1,2]
#         tags                  = { purpose = "app-workloads" }
#         node_labels           = { sku = "apps" }
#       }
#     }
# }
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }  
  }
}

provider "azurerm" {
  features {}
#  subscription_id = "b607d090-65bb-42fe-b80b-22ca0de642d3"
}

provider "kubernetes" {
  host                   = module.aks.kube_config_host
  client_certificate     = base64decode(module.aks.kube_config_client_certificate)
  client_key             = base64decode(module.aks.kube_config_client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config_cluster_ca_certificate)
}

# provider "helm" {
#   kubernetes {
#     host                   = module.aks.kube_config_host
#     client_certificate     = base64decode(module.aks.kube_config_client_certificate)
#     client_key             = base64decode(module.aks.kube_config_client_key)
#     cluster_ca_certificate = base64decode(module.aks.kube_config_cluster_ca_certificate)
#   }
#}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubectl" {
  config_path = "~/.kube/config"
}