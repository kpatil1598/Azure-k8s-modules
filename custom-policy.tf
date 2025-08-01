resource "azurerm_policy_definition" "storage_encryption_policy" {
  count        = can(var.regions_mapping["region_1"]) ? (var.regions_mapping["region_1"].s3_bucket_ai_transcribe_creation ? 1 : 0) : 0
  name         = "storage-account-encryption-enforcement"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Storage Account Encryption"
  description  = "storage accounts have encryption enabled"

## For DenyUnEncryptedObjectUploads
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        ## for condition
        {
          field = "Microsoft.Storage/storageAccounts/encryption.services.blob.enabled"
          equals = false
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_assignment" "encryption_assignment" {
  count                = can(var.regions_mapping["region_1"]) ? (var.regions_mapping["region_1"].s3_bucket_ai_transcribe_creation ? 1 : 0) : 0
  name                 = "storage-encryption-assignment"
  ## For resource scope targeting 
  scope                = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.storage_encryption_policy[0].id
  display_name         = "Storage Account Encryption Enforcement"
  description          = "Enforces encryption on storage accounts"
}
