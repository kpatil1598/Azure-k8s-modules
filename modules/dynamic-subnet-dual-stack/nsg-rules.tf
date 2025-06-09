# Example rule for public NSG: Allow SSH/HTTP/HTTPS
resource "azurerm_network_security_rule" "allow_inbound_http_https_ssh" {
  name                        = "allow-ssh-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "80", "443"] # Adjust as needed
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public.name
}
# Example rule for private NSG: Allow internal traffic
resource "azurerm_network_security_rule" "allow_internal_traffic" {
  name                        = "allow-internal-traffic"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "80", "443"] # Adjust as needed
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private.name
}
