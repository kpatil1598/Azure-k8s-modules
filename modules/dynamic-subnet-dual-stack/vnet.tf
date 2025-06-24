
resource "azurerm_virtual_network" "this" {
  name                = "aks-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_cidrs
  tags                = var.tags
 # enable_ipv6         = true
}

## working one ##
# resource "azurerm_subnet" "this" {
#   for_each             = { for s in local.all_subnets : s.name => s }
#   name                 = each.value.name
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.this.name
#   address_prefixes     = [each.value.cidr]


#   # Uncomment to enable AKS subnet delegation
#   # delegation {
#   #   name = "aks_delegation"
#   #   service_delegation {
#   #     name    = "Microsoft.ContainerService/managedClusters"
#   #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
#   #   }
#   # }
# }
resource "azurerm_subnet" "this" {
  for_each             = { for s in local.all_subnets : s.name => s }
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes = compact([
    each.value.cidr,
    each.value.ipv6_cidr
  ])
  

  # Uncomment for AKS delegation if needed
  # delegation {
  #   name = "aks_delegation"
  #   service_delegation {
  #     name    = "Microsoft.ContainerService/managedClusters"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  #   }
  # }
}