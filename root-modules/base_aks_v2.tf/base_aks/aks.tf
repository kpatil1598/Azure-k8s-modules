resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  oidc_issuer_enabled = true
  

  default_node_pool {
    name           = "critical"
    vm_size        = "Standard_B2s"
    node_count     = 2
    os_disk_size_gb = 50
   # os_disk_type        = "Linux"
    vnet_subnet_id = var.vnet_subnet_id
    zones          = var.default_node_pool.zones
    pod_subnet_id  = var.pod_subnet_id
    # node_taints is deprecated and should be set in a separate node pool resource if needed
  }

  identity {
    type = "SystemAssigned"
  }

     network_profile {
    network_plugin    = "azure"
    network_plugin_mode = "overlay"  # Use 'overlay' for dual-stack support
    #network_policy   = "calico"  # or "azure" for Azure CNI
  
    ip_versions       = ["IPv4","IPv6"]  # dual-stack configuration
    load_balancer_sku = "standard"

   # These match the `--pod-cidrs` argument
    pod_cidr           = null  # required to be null when using 'overlay' mode
    pod_cidrs          = ["10.2.0.0/20","fd12:3456:789a::/64"]

    # These match the `--service-cidrs` argument
    service_cidr       = null  # required to be null when using dual-stack
    service_cidrs      = ["10.1.0.0/20","fd12:3456:789a:1::/108"]  #["10.1.0.0/20"]

    dns_service_ip     = "10.1.0.10"
  }
  #  ingress_application_gateway {
  #   gateway_id = var.gateway_id
  # }
 # private_cluster_enabled           = false
  role_based_access_control_enabled = true
  workload_identity_enabled         = true
}

