terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.80.0"
    }
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = lower("${var.prefix}${random_string.suffix.result}")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}

resource "azurerm_storage_container" "content" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "${var.prefix}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  soft_delete_enabled      = true
  purge_protection_enabled = false
}

resource "random_password" "hmac_key" {
  length  = 32
  special = false
}

resource "azurerm_key_vault_secret" "hmac" {
  name         = "frontdoor-hmac-key"
  value        = random_password.hmac_key.result
  key_vault_id = azurerm_key_vault.kv.id
}

# Front Door profile
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
  name                = "${var.prefix}-fd"
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"
  location            = var.location
  identity { type = "SystemAssigned" }
}

# KV access policy for Front Door
resource "azurerm_key_vault_access_policy" "fd_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_cdn_frontdoor_profile.fd_profile.identity[0].principal_id

  secret_permissions = ["get", "list"]
}

# Front Door secret
resource "azurerm_cdn_frontdoor_secret" "fd_secret" {
  name                = "hmac-secret"
  resource_group_name = var.resource_group_name
  profile_name        = azurerm_cdn_frontdoor_profile.fd_profile.name
  key_vault_secret_id = azurerm_key_vault_secret.hmac.id
}

# Endpoint, origin group, origin
resource "azurerm_cdn_frontdoor_endpoint" "fd_endpoint" {
  name                = "${var.prefix}-ep"
  profile_name        = azurerm_cdn_frontdoor_profile.fd_profile.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_cdn_frontdoor_origin_group" "og" {
  name                = "${var.prefix}-og"
  profile_name        = azurerm_cdn_frontdoor_profile.fd_profile.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_cdn_frontdoor_origin" "origin" {
  name                = "${var.prefix}-origin"
  profile_name        = azurerm_cdn_frontdoor_profile.fd_profile.name
  resource_group_name = var.resource_group_name
  origin_group_name   = azurerm_cdn_frontdoor_origin_group.og.name
  host_name           = "${azurerm_storage_account.sa.name}.blob.core.windows.net"
  https_port          = 443
}

# Route + validation rule
resource "azurerm_cdn_frontdoor_rule" "validate" {
  name                = "validate-signedurl"
  profile_name        = azurerm_cdn_frontdoor_profile.fd_profile.name
  resource_group_name = var.resource_group_name

  route {
    name  = "blob-route"
    order = 1
    match_condition {
      name           = "AlwaysMatch"
      match_operator = "Any"
      match_values   = ["*"]
    }
    action {
      name                = "ValidateUrlSignature"
      secret_id           = azurerm_cdn_frontdoor_secret.fd_secret.id
      signature_parameter = "token"
      expires_parameter   = "expires"
      algorithm           = "HMACSHA256"
    }
    origin_group = azurerm_cdn_frontdoor_origin_group.og.name
  }
}

# variables
variable "prefix" {
  type        = string
  description = "Name prefix for resources"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant id"
}


# outputs
output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "container_name" {
  value = azurerm_storage_container.content.name
}

output "frontdoor_endpoint" {
  value = azurerm_cdn_frontdoor_endpoint.fd_endpoint.host_name
}

output "signing_secret" {
  value     = random_password.hmac_key.result
  sensitive = true
}
