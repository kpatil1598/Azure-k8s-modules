output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "private_subnet_ids" {
  value = [for subnet in azurerm_subnet.private : subnet.id]
}
output "route_table_id" {
  value = azurerm_route_table.this.id
}
