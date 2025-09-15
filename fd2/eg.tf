module "afd_url_signing" {
  source = "./modules/afd-url-signing"

  resource_group_name     = "rg-app-prod"
  profile_name            = "fd-prod-eu"
  secret_name             = "url-signing-k1"
  key_id                  = "k1"

  # Resource ID of the KV secret that stores your HMAC key
  # e.g.: /subscriptions/xxxx/resourceGroups/rg-kv/providers/Microsoft.KeyVault/vaults/app-kv/secrets/afd-signing-key
  key_vault_secret_id     = "/subscriptions/xxxx/resourceGroups/rg-kv/providers/Microsoft.KeyVault/vaults/app-kv/secrets/afd-signing-key"

  # apply to these paths (no leading slash)
  paths                   = ["private/*", "media/*"]

  # Optional: grant AFD MI read access to Key Vault via RBAC
  enable_kv_rbac          = true
  key_vault_id            = "/subscriptions/xxxx/resourceGroups/rg-kv/providers/Microsoft.KeyVault/vaults/app-kv"
  afd_identity_principal_id = "00000000-0000-0000-0000-000000000000" # Front Door profile MI object ID
}

resource "azurerm_cdn_frontdoor_route" "site_route" {
  # ...
  rule_set_ids = [
    module.afd_url_signing.rule_set_id
  ]
}
