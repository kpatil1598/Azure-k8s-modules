
# ---------- Outputs ----------
output "rule_id" {
  value       = azapi_resource.url_signing_rule.id
  description = "Resource ID of the UrlSigning rule"
}

output "secret_id" {
  value       = try(azapi_resource.url_signing_secret[0].id, null)
  description = "Resource ID of the UrlSigningKey secret (if created)"
}
