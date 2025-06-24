resource "azurerm_user_assigned_identity" "karpenter" {
  name                = "karpenter-uami"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# module "karpenter_role_assignment" {
#   source = "C:\\Users\\chava\\Desktop\\k8s-module\\modules\\role_assignment"

#   assignments = [
#     {
#       scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg-aks-dev"
#       role_name    = "Contributor"
#       principal_id = azurerm_user_assigned_identity.karpenter.principal_id
#      # principal_id = "chinmaychavan24_outlook.com#EXT#@chinmaychavan24outlook.onmicrosoft.com"
#     },
#     {
#       scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg-aks-dev"
#       role_name    = "Network Contributor"
#       principal_id = azurerm_user_assigned_identity.karpenter.principal_id
#     },
#     {
#       scope        ="/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg-aks-dev/providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/private-subnet-1"
#       role_name    = "managed identity operator"
#       principal_id = azurerm_user_assigned_identity.karpenter.principal_id
#     }
#   ]
#   depends_on = [ azurerm_user_assigned_identity.karpenter ]
# }
resource "azurerm_federated_identity_credential" "karpenter_federated_identity" {
  name                = "karpenter-federated-identity"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.issuer_url # Replace with your issuer URL
  # Example: "https://sts.windows.net/{tenant_id}/"
  parent_id           = azurerm_user_assigned_identity.karpenter.id
  # The parent_id should be the ID of the user-assigned identity
  #subject             = "system:serviceaccount:kube-system:karpenter"
  subject = "system:serviceaccount:karpenter:karpenter"
  depends_on = [ azurerm_user_assigned_identity.karpenter ]
}
resource "azurerm_role_assignment" "karpenter_contributor" {
  scope                = var.node_resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}