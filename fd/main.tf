terraform {
  required_version = ">= 1.4.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # URL signing in rules and Front Door Secret are stable in 3.x+ and 4.x.
      version = ">= 3.70.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# (Optional) grant AFD MI read access to the KV secret using RBAC
resource "azurerm_role_assignment" "afd_kv_secret_reader" {
  count                = var.enable_kv_rbac ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.afd_identity_principal_id
  # let terraform compute a stable GUID automatically
}

# 1) Create a Front Door Secret that references the KV secret containing the URL signing key
#    The Front Door Secret holds metadata, not the key material itself.
resource "azurerm_cdn_frontdoor_secret" "signing_key" {
  name                = var.secret_name
  resource_group_name = var.resource_group_name
  profile_name        = var.profile_name

  # Provider exposes a 'secret' block that can reference KV secrets for
  # different use-cases (TLS certs, URL signing keys). For URL signing keys
  # we identify the KV secret and set the Key ID used in signed URLs.
  secret {
    # Versioned or versionless ID of the KV secret
    key_vault_secret_id = var.key_vault_secret_id
    # If your provider requires explicit version, pass it (otherwise ignored)
    secret_version      = var.key_vault_secret_version

    # URL signing key parameters (maps the 'kid' your apps use to this secret)
    url_signing_key {
      key_id = var.key_id
    }
  }
}

# 2) Rule Set + Rule to enforce URL signatures
resource "azurerm_cdn_frontdoor_rule_set" "signing" {
  name                = var.rule_set_name
  resource_group_name = var.resource_group_name
  profile_name        = var.profile_name
}

resource "azurerm_cdn_frontdoor_rule" "require_signed" {
  name         = var.rule_name
  rule_set_id  = azurerm_cdn_frontdoor_rule_set.signing.id
  order        = 1
  behavior_on_match = "Continue" # enforce, then continue evaluating later rules if any

  # Match the requests you want to protect (NO leading slash)
  url_path_condition {
    operator     = "Equal"
    match_values = var.paths
  }

  # Enforce URL signing on matched requests
  url_signing_action {
    algorithm = var.algorithm

    # Override parameter names to match your app’s URLs
    parameter_name_override {
      expires   = var.param_expires
      key_id    = var.param_key_id
      signature = var.param_signature
    }

    # Tell AFD which secret to use based on the kid you supplied above
    # (AFD resolves the 'kid' to the secret you created)
    key_id  = var.key_id
    secret  = azurerm_cdn_frontdoor_secret.signing_key.id
  }

  depends_on = [
    azurerm_cdn_frontdoor_secret.signing_key
  ]
}
