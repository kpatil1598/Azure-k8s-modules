# This file defines the node pool for the Azure Kubernetes Service (AKS) cluster.
resource "azurerm_kubernetes_cluster_node_pool" "ats_nodegroup" {
  count = var.ats_node_pool_enabled ? 1 : 0 # Conditional creation based on variable
  name                  = "atsnodegroup"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_B2s"
  min_count             = 1
  max_count             = 2
  # node_count is not set when using min_count/max_count (autoscaling)
  mode                  = "User"
  os_type               = "Linux"
  os_disk_size_gb       = 30 # Adjusted disk size as needed
  # os_disk_type          = "Managed" # Optional, defaults to Managed
  #enable_host_encryption = true # Optional, enables disk encryption
  vnet_subnet_id        = var.vnet_subnet_id
  node_labels = {
    nodepool = "ats" # This label can be used to identify the node pool /need change
  }
   node_taints = [
    "manageedNodegroupATS=apps:NoSchedule"
  ]

  tags = {
    purpose = "app-workloads"
  }

  # upgrade_settings {
  #   max_surge = "1"
  # }

  # Optionally enable availability zones
  # availability_zones = ["1", "2"]

  lifecycle {
    ignore_changes = [node_count] # recommended when autoscaling is enabled
    
  }
}
