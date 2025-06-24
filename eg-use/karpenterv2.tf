# module "karpenter" {
#   source = "C:\\Users\\chava\\Desktop\\k8s-module\\modules\\karpenterv2"

#   location                 = "eastus"
#   resource_group_name      = module.resource_group.resource_group_name
#   node_resource_group_name = "MC_rg-aks-dev_aks-cluster_eastus"
#   node_resource_group_id   = data.azurerm_resource_group.node.id
#   subscription_id          = data.azurerm_client_config.current.subscription_id
#   tenant_id                = data.azurerm_client_config.current.tenant_id
#   cluster_name             = 
#   cluster_endpoint         = azurerm_kubernetes_cluster.aks.kube_config[0].host
#   oidc_issuer_url          = module.aks.issuer_url
# }
