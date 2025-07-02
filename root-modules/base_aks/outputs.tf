output "kube_config_raw" {
  description = "Raw kubeconfig to connect to AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
output "identity_principal_id" {
  description = "Managed identity for AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id  
}
output "issuer_url" {
  description = "Issuer URL for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}
# output "node_resource_group" {
#   value = data.azurerm_resource_group.node.id
# }


output "kube_config_host" {
  description = "Kubernetes cluster host"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
}

output "kube_config_client_certificate" {
  description = "Kubernetes cluster client certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
}

output "kube_config_client_key" {
  description = "Kubernetes cluster client key"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive   = true
}

output "kube_config_cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive   = true
}
output "node_resource_group" {
  description = "Node resource group ID for AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group  
}
# output "identity_id" {
#   description = "Managed identity ID for AKS cluste node poolr"
#   value       = data.azurerm_user_assigned_identity.agentpool.principal_id  
# }