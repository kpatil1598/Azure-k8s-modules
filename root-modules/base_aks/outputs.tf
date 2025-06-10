output "kube_config_raw" {
  description = "Raw kubeconfig to connect to AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
