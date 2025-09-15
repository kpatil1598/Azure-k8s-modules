# ---------- Inputs ----------
variable "profile_id" {
  description = "Resource ID of the Front Door (Standard/Premium) profile (Microsoft.Cdn/profiles/...)"
  type        = string
}

variable "rule_set_name" {
  description = "Name of the existing AFD Rule Set to add this rule to"
  type        = string
}

variable "rule_name" {
  description = "Name of the URL-signing rule to create"
  type        = string
  default     = "require-signed-urls"
}

variable "order" {
  description = "Evaluation order within the rule set"
  type        = number
  default     = 1
}

variable "match_values" {
  description = "URL path patterns to protect (use leading slash)"
  type        = list(string)
  default     = ["/protected/*"]
}

variable "algorithm" {
  description = "Signing algorithm; AFD currently supports SHA256"
  type        = string
  default     = "SHA256"
}

variable "parameter_names" {
  description = "Query parameter names used in your signed URLs"
  type = object({
    expires   = string # e.g., "exp"
    keyid     = string # e.g., "kid"
    signature = string # e.g., "sig"
  })
  default = {
    expires   = "exp"
    keyid     = "kid"
    signature = "sig"
  }
}

# --- Optional: also create the UrlSigningKey secret in AFD from a Key Vault secret ---
variable "create_secret" {
  description = "Whether to create the UrlSigningKey secret in AFD"
  type        = bool
  default     = false
}

variable "signing_key_name" {
  description = "AFD Secret name to create (when create_secret=true)"
  type        = string
  default     = null
}

variable "key_id" {
  description = "Customer-defined key ID (the value your signer will put into the 'kid' query param)"
  type        = string
  default     = null
}

variable "key_vault_secret_id" {
  description = "Resource ID of the Key Vault secret (…/vaults/<kv>/secrets/<name>)"
  type        = string
  default     = null
}

variable "key_vault_secret_version" {
  description = "Version of the Key Vault secret (or null to use latest)"
  type        = string
  default     = null
}
