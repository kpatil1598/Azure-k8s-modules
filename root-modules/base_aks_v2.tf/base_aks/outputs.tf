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