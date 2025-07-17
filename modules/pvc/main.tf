resource "kubernetes_persistent_volume_claim_v1" "azure_blob" {
  metadata {
    name      = var.pvc_name
    namespace = var.namespace
  }

  spec {
    access_modes = var.access_modes
    
    resources {
      requests = {
        storage = var.storage_size
      }
    }

    volume_name        = var.volume_name
    storage_class_name = var.storage_class_name
  }
}