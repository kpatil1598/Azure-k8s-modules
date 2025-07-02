data "azurerm_user_assigned_identity" "agentpool" {
  name                = "${var.cluster_name}-agentpool"
  resource_group_name = "MC_${var.resource_group_name}_${var.cluster_name}_${var.location}"
}

# Assign "Virtual Machine Contributor" on Node Resource Group
resource "azurerm_role_assignment" "karpenter_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.agentpool.principal_id
}
