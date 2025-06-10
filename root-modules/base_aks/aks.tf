resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  oidc_issuer_enabled = true

  default_node_pool {
    name            = var.default_node_pool.name
    vm_size         = var.default_node_pool.vm_size
    node_count      = var.default_node_pool.node_count
    vnet_subnet_id  = var.vnet_subnet_id
    zones           = var.default_node_pool.zones
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
  }

  role_based_access_control_enabled = true
  workload_identity_enabled         = true
}

resource "azurerm_kubernetes_cluster_node_pool" "extra" {
  for_each = var.nodepools

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  enable_auto_scaling   = each.value.enable_auto_scaling
  vnet_subnet_id        = each.value.vnet_subnet_id
  enable_node_public_ip = each.value.enable_node_public_ip
  zones                 = each.value.zones
  tags                  = each.value.tags
  node_labels           = each.value.node_labels
}
