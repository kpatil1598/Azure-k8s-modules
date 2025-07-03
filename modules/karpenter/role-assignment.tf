# Role assignment for Karpenter managed identity to read VNET
# This is now handled in user_identity.tf through the role assignment module
# Keeping this file for reference but removing the duplicate assignment 
# Role assignment for Karpenter managed identity to read VNET
# This is now handled in user_identity.tf through the role assignment module
# Keeping this file for reference but removing the duplicate assignment 
# Get AKS Client Config
data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "karpenter" {
  name                = "karpenter-uami"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Federated Identity Credential
resource "azurerm_federated_identity_credential" "karpenter_federated_identity" {
  name                = "karpenter-federated-identity"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.issuer_url # Should be your AKS OIDC issuer URL
  parent_id           = azurerm_user_assigned_identity.karpenter.id
  subject             = "system:serviceaccount:kube-system:karpenter"
  depends_on = [azurerm_user_assigned_identity.karpenter]
}

# Assign "Virtual Machine Contributor" on Node Resource Group
resource "azurerm_role_assignment" "karpenter_vm_contributor" {
  scope                = data.azurerm_resource_group.node_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}

# Assign "Network Contributor" on Subnet
resource "azurerm_role_assignment" "karpenter_network_contributor" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}

# Optional: Assign "Reader" role on AKS cluster RG (for Karpenter to read cluster info)
resource "azurerm_role_assignment" "karpenter_reader_aks_rg" {
  scope                = data.azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}

# Optional: If your bootstrap process requires managed identity to assign identity to VMs
resource "azurerm_role_assignment" "karpenter_mi_operator" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.node_resource_group}"
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}
resource "azurerm_role_assignment" "karpenter_cotributor_node_rg" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.node_resource_group}"
  role_definition_name = "contributor"
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}
resource "azurerm_role_assignment" "karpenter_contibutor_rg" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "contributor"
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}
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
# Add time delay to ensure role assignments propagate
resource "time_sleep" "wait_for_rbac" {
  depends_on = [
    azurerm_role_assignment.karpenter_vm_contributor,
    azurerm_role_assignment.karpenter_network_contributor,
    azurerm_role_assignment.karpenter_reader_aks_rg,
    azurerm_role_assignment.karpenter_mi_operator
  ]
  create_duration = "60s"
}
