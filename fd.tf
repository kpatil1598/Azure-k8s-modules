# Front Door Profile with Managed Identity
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
  name                = "fd-profile-identity"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Premium_AzureFrontDoor"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.fd_identity.id]
  }
}
resource "azurerm_cdn_frontdoor_endpoint" "fd_endpoint" {
  name                     = "fd-endpoint-identity"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
}
resource "azurerm_cdn_frontdoor_origin_group" "fd_origin_group" {
  name                     = "fd-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
}
resource "azurerm_cdn_frontdoor_origin" "fd_origin" {
  name                          = "storage-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id
  enabled                       = true
  host_name                     = azurerm_storage_account.sa.primary_blob_host
  origin_host_header            = azurerm_storage_account.sa.primary_blob_host
  http_port                     = 80
  https_port                    = 443
  # Identity settings
  certificate_name_check_enabled = true
  enabled                        = true
  # This is important for auth
  origin_identity {
    type      = "UserAssigned"
    identity  = azurerm_user_assigned_identity.fd_identity.id
  }
}
resource "azurerm_cdn_frontdoor_route" "fd_route" {
  name                          = "fd-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fd_origin.id]
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/*"]
  https_redirect_enabled        = true
  enabled                       = true
}
