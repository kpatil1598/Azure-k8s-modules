data "azurerm_client_config" "current" {}
data "azurerm_resource_group" "node" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}
#Data source to get the VNET information
# data "azurerm_virtual_network" "aks_vnet" {
#   name                = "aks-vnet"
#   resource_group_name = var.resource_group_name
# }