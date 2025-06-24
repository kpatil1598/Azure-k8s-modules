resource "azurerm_user_assigned_identity" "agic" {
  name                = "${var.name}-agic-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "agic_network_contributor" {
  scope                = var.appgw_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.agic.principal_id
}

resource "azurerm_role_assignment" "agic_reader_rg" {
  scope                = var.appgw_rg_scope
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.agic.principal_id
}
