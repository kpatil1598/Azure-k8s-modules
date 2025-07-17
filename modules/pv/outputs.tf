output "pv_name" {
  description = "Name of the created PersistentVolume"
  value       = kubernetes_persistent_volume_v1.azure_blob.metadata[0].name
}

output "pv_uid" {
  description = "UID of the created PersistentVolume"
  value       = kubernetes_persistent_volume_v1.azure_blob.metadata[0].uid
}