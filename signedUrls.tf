terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.76.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" { type = string }
variable "profile_name"        { type = string } # AFD Standard/Premium profile
variable "rule_set_name"       { type = string  default = "url-signing-rs" }
variable "rule_name"           { type = string  default = "url-signing" }
variable "order"               { type = number  default = 1 }

# One Key Vault secret that contains your HMAC signing key (as plain text)
# This module will expose it to AFD as a Front Door Secret with a Key ID.
variable "kv_secret_id" { type = string }  # /subscriptions/.../vaults/<kv>/secrets/<name>
variable "key_id"       { type = string }  # e.g., "key1"

# Attach this ruleset to these Front Door Route IDs.
variable "route_ids" { type = list(string) } # e.g., [azurerm_cdn_frontdoor_route.app1.id]

# Limit where signing is applied (match on URL path). IMPORTANT: no leading slash per provider rule. e.g., ["private/*"]
# If empty, the rule will apply to all requests.
variable "paths_to_sign" {
  type    = list(string)
  default = []
}

# Optional: override query parameter names that AFD writes
variable "param_name_expires"   { type = string default = "exp" }
variable "param_name_keyid"     { type = string default = "kid" }
variable "param_name_signature" { type = string default = "sig" }

# 1) Front Door Rule Set
resource "azurerm_cdn_frontdoor_rule_set" "this" {
  name                = var.rule_set_name
  profile_name        = var.profile_name
  resource_group_name = var.resource_group_name
}

# 2) Front Door Secret (URL Signing key) via AzAPI to ensure latest schema
#    (works even if your azurerm provider is older)
resource "azapi_resource" "url_signing_secret" {
  type      = "Microsoft.Cdn/profiles/secrets@2025-04-15"
  name      = "${var.key_id}-signing-secret"
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Cdn/profiles/${var.profile_name}"
  body = {
    properties = {
      parameters = {
        typeName      = "UrlSigningKeyParameters"
        keyId         = var.key_id
        secretSource  = { id = var.kv_secret_id }
        # secretVersion can be omitted to always use the latest version, or set explicitly
        # secretVersion = "<specific-version-guid>"
      }
    }
  }
}

data "azurerm_client_config" "current" {}

# 3) Front Door Rule with UrlSigning action
#    NOTE: When using a "URL Path" match condition, provider expects values WITHOUT a leading slash.
#    Example: "private/*" (not "/private/*"). :contentReference[oaicite:1]{index=1}
resource "azurerm_cdn_frontdoor_rule" "sign_url" {
  name                = var.rule_name
  profile_name        = var.profile_name
  resource_group_name = var.resource_group_name
  rule_set_name       = azurerm_cdn_frontdoor_rule_set.this.name
  order               = var.order

  dynamic "conditions" {
    for_each = length(var.paths_to_sign) == 0 ? [] : [1]
    content {
      url_path_condition {
        operator     = "Wildcard"
        negate       = false
        match_values = var.paths_to_sign
        transforms   = []
      }
    }
  }

  actions {
    # SHA256 is the only supported algorithm in AFD URL Signing at time of writing. :contentReference[oaicite:2]{index=2}
    url_signing_action {
      algorithm = "SHA256"

      parameter_name_override {
        param_indicator = "Expires"   # required enum
        param_name      = var.param_name_expires
      }
      parameter_name_override {
        param_indicator = "KeyId"
        param_name      = var.param_name_keyid
      }
      parameter_name_override {
        param_indicator = "Signature"
        param_name      = var.param_name_signature
      }
    }
  }

  # Make sure origins & the secret exist before rule creation
  depends_on = [azapi_resource.url_signing_secret]
}

# 4) Attach the rule set to routes
resource "azurerm_cdn_frontdoor_rule_set_route" "attach" {
  for_each                  = toset(var.route_ids)
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.this.id
  cdn_frontdoor_route_id    = each.value
}

output "url_signing_secret_name" {
  value = azapi_resource.url_signing_secret.name
}

# How to use it
module "afd_url_signing" {
  source              = "./modules/afd-url-signing"

  resource_group_name = azurerm_resource_group.rg.name
  profile_name        = azurerm_cdn_frontdoor_profile.afd.name

  # Key Vault secret that holds your HMAC key (string)
  kv_secret_id = azurerm_key_vault_secret.afd_signing_key.id
  key_id       = "key1"

  # Apply to these Front Door routes
  route_ids = [
    azurerm_cdn_frontdoor_route.app_api.id
  ]

  # Only sign URLs under these paths (no leading slash)
  paths_to_sign = ["private/*", "downloads/*"]

  # Optional: query param names
  param_name_expires   = "exp"
  param_name_keyid     = "kid"
  param_name_signature = "sig"
}
