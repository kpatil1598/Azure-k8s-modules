data "azurerm_client_config" "current" {}
data "azurerm_resource_group" "node" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}
