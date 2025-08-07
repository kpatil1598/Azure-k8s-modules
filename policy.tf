resource "azurerm_policy_set_definition" "storage_security_baseline" {
  name         = "storage-security-baseline"
  display_name = "Storage Security Baseline"
  policy_type  = "Custom"
  description  = "Initiative to enforce storage security policies"
  management_group_id = "/providers/Microsoft.Management/managementGroups/my-mg-id" # Optional: use `subscription_id` for subscription scope
  policy_definitions = [
    {
      policy_definition_id = azurerm_policy_definition.deny_public_blob.id
      parameters            = jsonencode({})
    },
    {
      policy_definition_id = azurerm_policy_definition.enforce_cmk.id
      parameters            = jsonencode({})
    }
  ]
}
