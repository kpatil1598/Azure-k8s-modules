resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space       = var.vnet_address_space
  ipv6_address_space  = var.vnet_ipv6_space

  enable_ddos_protection = false
}

resource "azurerm_subnet" "public" {
  name                 = var.public_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet_prefix]
  ipv6_prefix          = var.public_subnet_ipv6_prefix
}

resource "azurerm_subnet" "private" {
  count                = 3
  name                 = "${var.private_subnet_prefix}-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnet_prefixes[count.index]]
  ipv6_prefix          = var.private_subnet_ipv6_prefixes[count.index]
}
