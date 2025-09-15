terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.13.0"
    }
  }
}


# ---------- Locals ----------
locals {
  rule_set_parent_id = "${var.profile_id}/ruleSets/${var.rule_set_name}"
}

# ---------- (Optional) AFD UrlSigningKey Secret ----------
resource "azapi_resource" "url_signing_secret" {
  count     = var.create_secret ? 1 : 0
  type      = "Microsoft.Cdn/profiles/secrets@2025-04-15"
  name      = var.signing_key_name
  parent_id = var.profile_id

  body = jsonencode({
    properties = {
      parameters = {
        type          = "UrlSigningKey"
        keyId         = var.key_id
        secretSource  = { id = var.key_vault_secret_id }
        secretVersion = var.key_vault_secret_version
      }
    }
  })
}

# ---------- AFD Rule with UrlSigning Action ----------
resource "azapi_resource" "url_signing_rule" {
  type      = "Microsoft.Cdn/profiles/rulesets/rules@2025-04-15"
  name      = var.rule_name
  parent_id = local.rule_set_parent_id

  # Ensure the secret exists first if we are creating it here
  depends_on = [for s in azapi_resource.url_signing_secret : s]

  body = jsonencode({
    properties = {
      order = var.order

      conditions = [
        {
          name       = "UrlPath"
          parameters = {
            typeName        = "DeliveryRuleUrlPathMatchConditionParameters"
            operator        = "Wildcard"
            negateCondition = false
            matchValues     = var.match_values
            transforms      = []
          }
        }
      ]

      actions = [
        {
          name       = "UrlSigning"
          parameters = {
            typeName              = "DeliveryRuleUrlSigningActionParameters"
            algorithm             = var.algorithm
            parameterNameOverride = [
              { paramIndicator = "Expires",   paramName = var.parameter_names.expires },
              { paramIndicator = "KeyId",     paramName = var.parameter_names.keyid },
              { paramIndicator = "Signature", paramName = var.parameter_names.signature }
            ]
          }
        }
      ]

      matchProcessingBehavior = "Continue"
    }
  })
}
