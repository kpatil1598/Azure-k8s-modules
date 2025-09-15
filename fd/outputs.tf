output "frontdoor_secret_id" {
  description = "ID of the Front Door Secret that references the signing key."
  value       = azurerm_cdn_frontdoor_secret.signing_key.id
}

output "rule_set_id" {
  description = "ID of the rule set you can associate with your routes."
  value       = azurerm_cdn_frontdoor_rule_set.signing.id
}

output "rule_id" {
  description = "ID of the URL-signing enforcement rule."
  value       = azurerm_cdn_frontdoor_rule.require_signed.id
}
