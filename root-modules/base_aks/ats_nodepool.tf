resource "azurerm_kubernetes_cluster_node_pool" "extra" {
    count = ats_node_pool_enable ? 1 : 0 
  for_each = var.nodepools

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  enable_auto_scaling   = each.value.enable_auto_scaling
  vnet_subnet_id = each.value.vnet_subnet_id
  #enable_node_public_ip = each.value.enable_node_public_ip
  zones       = each.value.zones
  tags        = each.value.tags
  node_labels = each.value.node_labels
}