module "network" {
  source = "..\\modules\\dynamic-subnet-dual-stack"
  # ... pass vnet_name, subnet_name, etc.
}

module "aks" {
  source              = "..\\root-modules\\aks"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = "aks-cluster"
  dns_prefix          = "akscluster"
  kubernetes_version  = "1.25.4"
  vnet_subnet_id      = var.private_subnet_cidrs # Adjust based on your vnet module output

  default_node_pool = {
    name       = "system"
    vm_size    = "Standard_DS2_v2"
    node_count = 3
    zones      = [1,2,3]
  }

  nodepools = {
     ats_nodegroup = {
      name                  = "ats-nodegroup"
      vm_size               = "Standard_NC6"
      min_count             = 1
      max_count             = 2
      enable_auto_scaling   = true
      vnet_subnet_id        = module.network.az_subnet_id
      enable_node_public_ip = false
      zones                 = [1,2]
      tags                  = { purpose = "app-workloads" }
      node_labels           = { sku = "apps" }
    }
  }
}
