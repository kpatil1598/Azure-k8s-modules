variable "resource_group_name" {
  description = "Resource group of the Front Door profile."
  type        = string
}

variable "profile_name" {
  description = "Front Door Standard/Premium profile name."
  type        = string
}

variable "secret_name" {
  description = "Name to give the Front Door Secret that holds the URL signing key reference."
  type        = string
  default     = "url-signing-k1"
}

variable "key_id" {
  description = "Customer-defined Key ID (kid). This must match the kid your apps put into signed URLs."
  type        = string
  default     = "k1"
}

variable "key_vault_secret_id" {
  description = "Full resource ID of the Key Vault secret that stores the private signing key."
  type        = string
}

variable "key_vault_secret_version" {
  description = "Specific version of the Key Vault secret. Omit to use the current version."
  type        = string
  default     = null
}

variable "rule_set_name" {
  description = "Name for the AFD Rule Set that enforces URL signing."
  type        = string
  default     = "url-signing-rs"
}

variable "rule_name" {
  description = "Name for the rule inside the rule set."
  type        = string
  default     = "require-signed-urls"
}

variable "paths" {
  description = <<EOT
List of URL path patterns (no leading slash). Examples:
["*", "private/*", "assets/*.jpg"]
EOT
  type        = list(string)
  default     = ["*"]
}

variable "algorithm" {
  description = "Hash algorithm used for signing."
  type        = string
  default     = "SHA256"
}

variable "param_expires" {
  description = "Query parameter name for the expiration (e.g., exp)."
  type        = string
  default     = "exp"
}

variable "param_key_id" {
  description = "Query parameter name for the key id (e.g., kid)."
  type        = string
  default     = "kid"
}

variable "param_signature" {
  description = "Query parameter name for the signature (e.g., sig)."
  type        = string
  default     = "sig"
}

# Optional: let the module grant Front Door access to your Key Vault secret
variable "enable_kv_rbac" {
  description = "If true, create RBAC role assignment 'Key Vault Secrets User' for AFD MI on the Key Vault."
  type        = bool
  default     = false
}

variable "key_vault_id" {
  description = "Key Vault resource ID (required only if enable_kv_rbac is true)."
  type        = string
  default     = null
}

variable "afd_identity_principal_id" {
  description = "Principal (object) ID of the Front Door profile's managed identity (required only if enable_kv_rbac is true)."
  type        = string
  default     = null
}
