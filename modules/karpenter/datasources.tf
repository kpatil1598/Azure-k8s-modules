

# Data source to get the VNET information
data "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}
data "azurerm_resource_group" "node_rg" {
  name = var.node_resource_group
}
data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}
