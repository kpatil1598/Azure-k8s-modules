# module "network" {
#   source = "..\\modules\\dynamic-subnet-dual-stack"
#   # ... pass vnet_name, subnet_name, etc.
# }

module "aks" {
  source              = "..\\root-modules\\base_aks"
  resource_group_name = module.resource_group.resource_group_name
  location            = "eastus"
  cluster_name        = "aks-cluster"
  dns_prefix          = "akscluster"
  kubernetes_version  = "1.33.0"
  vnet_subnet_id      = values(module.networking.private_subnet_ids)[0] # Adjust based on your vnet module output

  default_node_pool = {
    name       = "system"
    vm_size    = "Standard_B2s"
    node_count = 1
   # zones      = [1,3]
    upgrade_settings ={
      max_surge = "1"           # Minimal surge capacity during upgrades
    }
  }

  nodepools = {
     ats_nodegroup = {
      name                  = "atsnodegroup"
      vm_size               = "Standard_B2s"
      min_count             = 1
      max_count             = 2
      enable_auto_scaling   = true
      vnet_subnet_id        = values(module.networking.private_subnet_ids)[0]
     # zones                 = [1,2]
      tags                  = { purpose = "app-workloads" }
      node_labels           = { sku = "apps" }
    }
  }
 }
