resource "kubernetes_persistent_volume_v1" "azure_blob" {
  metadata {
    name = var.pv_name
    annotations = {
      "pv.kubernetes.io/provisioned-by" = "blob.csi.azure.com"
    }
  }

  spec {
    capacity = {
      storage = var.storage_size
    }

    access_modes = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = var.reclaim_policy
    storage_class_name = var.storage_class_name
    mount_options = var.mount_options

  csi {
    driver = "blob.csi.azure.com"
    volume_handle = var.volume_handle
      
    volume_attributes = {
    containerName = var.container_name
  }

  node_stage_secret_ref {
        name      = var.secret_name
        namespace = var.namespace
      }
    }
  }
}