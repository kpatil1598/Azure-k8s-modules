data "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-cluster"
  resource_group_name = "rg-aks-dev"
}

# data "azurerm_resource_group" "aks" {
#   name = "rg-aks-dev"
# }

module "karpenter" {
  source = "C:\\Users\\chava\\Desktop\\k8s-module\\modules\\karpenter"  # adjust path as needed

  name                   = "karpenter"
  location               = "eastus"
  resource_group_name    = "rg-aks-dev"
  node_resource_group    = "rg-aks-dev"
  cluster_name               = "aks-cluster"
  aks_api_server         = data.azurerm_kubernetes_cluster.aks.kube_config[0].host

  #clusrer_endpoint       = data.azurerm_kubernetes_cluster.aks.kube_config[0].host

  aks_host               = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = data.azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  client_key             = data.azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  cluster_ca_certificate = data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate

  subscription_id        = "${data.azurerm_client_config.current.subscription_id}"
  subnet_id              = "/subscriptions/f7c3be65-2edf-420b-9d7b-25bca67f650c/resourceGroups/rg-aks-dev/providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/private-subnet-1"

  #karpenter_version           = "0.36.1"
  #karpenter_provider_version  = "0.0.17"
  issuer_url            = module.aks.issuer_url  # Replace with your actual issuer URL
}            # set matching version

