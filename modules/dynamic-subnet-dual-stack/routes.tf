# 

##NAT-GATEWAY##

# Public Route Table (for public subnets)
resource "azurerm_route_table" "public" {
  name                = "rt-public"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name           = "internet-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = var.tags
}

# Private Route Table (no explicit internet route here)
resource "azurerm_route_table" "private" {
  name                = "rt-private"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Route table association for public subnets
resource "azurerm_subnet_route_table_association" "public" {
  for_each = {
    for s in local.public_subnets : s.name => s
  }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.public.id
}

# Route table association for private subnets
resource "azurerm_subnet_route_table_association" "private" {
  for_each = {
    for s in local.private_subnets : s.name => s
  }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.private.id
}
