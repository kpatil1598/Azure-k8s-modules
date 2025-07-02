# resource "azurerm_user_assigned_identity" "karpenter" {
#   name                = "karpenter-uami"
#   resource_group_name = var.resource_group_name
#   location            = var.location
# }

# # Federated Identity Credential
# resource "azurerm_federated_identity_credential" "karpenter_federated_identity" {
#   name                = "karpenter-federated-identity"
#   resource_group_name = var.resource_group_name
#   audience            = ["api://AzureADTokenExchange"]
#   issuer              = var.issuer_url # Should be your AKS OIDC issuer URL
#   parent_id           = azurerm_user_assigned_identity.karpenter.id
#   subject             = "system:serviceaccount:kube-system:karpenter"
  
#   depends_on = [azurerm_user_assigned_identity.karpenter]
# }

# # Role Assignments - Fixed scopes and added missing roles
# resource "azurerm_role_assignment" "karpenter_reader" {
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
#   role_definition_name = "Reader"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }

# resource "azurerm_role_assignment" "karpenter_network_contributor_main" {
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }

# resource "azurerm_role_assignment" "karpenter_vm_contributor" {
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.node_resource_group}"
#   role_definition_name = "Virtual Machine Contributor"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }

# resource "azurerm_role_assignment" "karpenter_network_contributor_node" {
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.node_resource_group}"
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }

# resource "azurerm_role_assignment" "karpenter_managed_identity_operator" {
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.node_resource_group}"
#   role_definition_name = "Managed Identity Operator"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }

# # CRITICAL: Network Contributor at VNET level (not just subnet)
# resource "azurerm_role_assignment" "karpenter_vnet_network_contributor" {
#   scope                = data.azurerm_virtual_network.aks_vnet.id
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }

# # Reader at VNET level for read operations
# resource "azurerm_role_assignment" "karpenter_vnet_reader" {
#   scope                = data.azurerm_virtual_network.aks_vnet.id
#   role_definition_name = "Reader"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }

# # Network Contributor at subnet level
# resource "azurerm_role_assignment" "karpenter_subnet_network_contributor" {
#   scope                = "${data.azurerm_virtual_network.aks_vnet.id}/subnets/${var.subnet_name}"
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }

# # Add time delay to ensure role assignments propagate
# resource "time_sleep" "wait_for_rbac" {
#   depends_on = [
#     azurerm_role_assignment.karpenter_reader,
#     azurerm_role_assignment.karpenter_network_contributor_main,
#     azurerm_role_assignment.karpenter_vm_contributor,
#     azurerm_role_assignment.karpenter_network_contributor_node,
#     azurerm_role_assignment.karpenter_managed_identity_operator,
#     azurerm_role_assignment.karpenter_vnet_network_contributor,
#     azurerm_role_assignment.karpenter_vnet_reader,
#     azurerm_role_assignment.karpenter_subnet_network_contributor,
#     azurerm_federated_identity_credential.karpenter_federated_identity
#   ]
#   create_duration = "60s"
# }