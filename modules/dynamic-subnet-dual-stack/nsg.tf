# Private NSG
resource "azurerm_network_security_group" "private" {
  name                = "nsg-private"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Public NSG
resource "azurerm_network_security_group" "public" {
  name                = "nsg-public"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Associate private NSG with private subnets
resource "azurerm_subnet_network_security_group_association" "private" {
  for_each = { for s in local.private_subnets : s.name => s }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.private.id
}

# Associate public NSG with public subnets
resource "azurerm_subnet_network_security_group_association" "public" {
  for_each = { for s in local.public_subnets : s.name => s }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.public.id
}
