resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  oidc_issuer_enabled = true

  default_node_pool {
    name           = var.default_node_pool.name
    vm_size        = var.default_node_pool.vm_size
    node_count     = var.default_node_pool.node_count
    vnet_subnet_id = var.vnet_subnet_id
    zones          = var.default_node_pool.zones
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    ip_versions       = ["IPv4","IPv6"]
    load_balancer_sku = "standard"
    network_plugin_mode = "overlay" 
    #docker_bridge_cidr  = "172.17.0.1/16"
    service_cidr   = "10.1.0.0/20"
    dns_service_ip = "10.1.0.10"
  }
  role_based_access_control_enabled = true
  workload_identity_enabled         = true
}


