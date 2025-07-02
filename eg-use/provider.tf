terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
#provider "kubernetes" {
#   host                   = module.aks.kube_config_host
#   client_certificate     = base64decode(module.aks.kube_config_client_certificate)
#   client_key             = base64decode(module.aks.kube_config_client_key)
#   cluster_ca_certificate = base64decode(module.aks.kube_config_cluster_ca_certificate)
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.aks.kube_config_host
#     client_certificate     = base64decode(module.aks.kube_config_client_certificate)
#     client_key             = base64decode(module.aks.kube_config_client_key)
#     cluster_ca_certificate = base64decode(module.aks.kube_config_cluster_ca_certificate)
#   }
# }


terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "terraformtfstate2025"
    container_name       = "terrafom-tfstate-aks"
    key                  = "terraform.tfstate"
  }
}