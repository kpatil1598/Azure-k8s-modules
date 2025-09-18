provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-afd"
  location = "East US"
}

resource "azurerm_storage_account" "sa" {
  name                     = "myuniquestorage123"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# -------- Bash Script Integration --------
resource "null_resource" "generate_sas" {
  provisioner "local-exec" {
    command = <<EOT
    bash generate_sas.sh ${azurerm_resource_group.rg.name} ${azurerm_storage_account.sa.name} ${azurerm_storage_container.container.name} sample.jpg 60
    EOT
  }
}

# Read the SAS token from file
data "local_file" "sas_token_file" {
  filename = "${path.module}/sas_output.env"
}

locals {
  sas_token = regex("sas_token=(.*)", data.local_file.sas_token_file.content)[0]
}


# -------- Front Door Profile --------
resource "azurerm_cdn_frontdoor_profile" "afd" {
  name                = "afd-signed-url-demo"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Premium_AzureFrontDoor"
}

# -------- Front Door Endpoint --------
resource "azurerm_cdn_frontdoor_endpoint" "afd_endpoint" {
  name                     = "demo-endpoint"
  profile_name             = azurerm_cdn_frontdoor_profile.afd.name
  resource_group_name      = azurerm_resource_group.rg.name
}

# -------- Origin Group with Storage Endpoint --------
resource "azurerm_cdn_frontdoor_origin_group" "og" {
  name                     = "origin-group"
  profile_name             = azurerm_cdn_frontdoor_profile.afd.name
  resource_group_name      = azurerm_resource_group.rg.name
  session_affinity_enabled = false
  health_probe {
    protocol = "Https"
    path     = "/sample.jpg"
    interval_in_seconds = 60
  }
}

resource "azurerm_cdn_frontdoor_origin" "origin" {
  name                          = "storage-origin"
  origin_group_name             = azurerm_cdn_frontdoor_origin_group.og.name
  profile_name                  = azurerm_cdn_frontdoor_profile.afd.name
  resource_group_name           = azurerm_resource_group.rg.name
  host_name                     = "${azurerm_storage_account.sa.name}.blob.core.windows.net"
  http_port                     = 80
  https_port                    = 443
  enabled                       = true
  origin_host_header            = "${azurerm_storage_account.sa.name}.blob.core.windows.net"
  priority                      = 1
  weight                        = 1000
}

# -------- Front Door Route --------
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "route1"
  profile_name                  = azurerm_cdn_frontdoor_profile.afd.name
  resource_group_name           = azurerm_resource_group.rg.name
  endpoint_name                 = azurerm_cdn_frontdoor_endpoint.afd_endpoint.name
  origin_group_name             = azurerm_cdn_frontdoor_origin_group.og.name
  supported_protocols           = ["Https"]
  patterns_to_match             = ["/images/*"]
  forwarding_protocol           = "MatchRequest"
  enabled                       = true
  cdn_frontdoor_rule_set_ids    = [azurerm_cdn_frontdoor_rule_set.inject_sas.id]
}

# -------- Rules Engine to Inject SAS Token --------
resource "azurerm_cdn_frontdoor_rule_set" "inject_sas" {
  name                = "inject-sas-rule"
  profile_name        = azurerm_cdn_frontdoor_profile.afd.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_cdn_frontdoor_rule" "sas_rule" {
  name                = "sas-token-injection"
  rule_set_name       = azurerm_cdn_frontdoor_rule_set.inject_sas.name
  profile_name        = azurerm_cdn_frontdoor_profile.afd.name
  resource_group_name = azurerm_resource_group.rg.name
  order               = 1
  behavior_on_match   = "Continue"

  action {
    name = "UrlRewrite"
    url_rewrite_action {
      source_pattern = "/images/(.*)"
      destination    = "/images/\\1?${local.sas_token}"
    }
  }

  condition {
    name         = "UrlPath"
    operator     = "BeginsWith"
    match_values = ["/images/"]
  }
}

