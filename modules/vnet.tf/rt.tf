resource "azurerm_route_table" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_route" "default" {
  count                   = var.create_default_route ? 1 : 0
  name                    = "default-route"
  resource_group_name     = var.resource_group_name
  route_table_name        = azurerm_route_table.this.name
  address_prefix          = "0.0.0.0/0"
  next_hop_type           = var.next_hop_type
  next_hop_in_ip_address  = var.next_hop_type == "VirtualAppliance" ? var.next_hop_ip : null
}

resource "azurerm_subnet_route_table_association" "assoc" {
  subnet_id      = var.subnet_id
  route_table_id = azurerm_route_table.this.id
}
