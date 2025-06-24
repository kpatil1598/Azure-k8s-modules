# module "network_contributor_assignment" {
#   source = "../../modules/role_assignment"

#   assignments = [
#     {
#       scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg-aks-dev"
#       role_name    = "Network Contributor"
#       principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
#      # principal_id = "chinmaychavan24_outlook.com#EXT#@chinmaychavan24outlook.onmicrosoft.com"
#     }
#   ]
# }
resource "azurerm_role_assignment" "aks_network" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
