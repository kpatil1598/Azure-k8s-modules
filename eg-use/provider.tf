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