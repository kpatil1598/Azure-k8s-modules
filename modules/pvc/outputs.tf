output "pvc_name" {
  description = "Name of the created PersistentVolumeClaim"
  value       = kubernetes_persistent_volume_claim_v1.azure_blob.metadata[0].name
}

output "pvc_namespace" {
  description = "Namespace of the created PersistentVolumeClaim"
  value       = kubernetes_persistent_volume_claim_v1.azure_blob.metadata[0].namespace
}

output "status" {
  description = "Status of the PVC"
  value       = kubernetes_persistent_volume_claim_v1.azure_blob.status[0].phase
  sensitive   = true
}