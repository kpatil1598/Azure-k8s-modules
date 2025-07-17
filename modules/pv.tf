resource "kubernetes_persistent_volume" "example" {
  metadata {
    name = "example-pv"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/mnt/data"
      }
    }
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "manual"
  }
}
resource "kubernetes_persistent_volume_claim" "example" {
  metadata {
    name = "example-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = "manual"
  }
}
