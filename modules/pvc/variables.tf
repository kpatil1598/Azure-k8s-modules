variable "pvc_name" {
  description = "Name of the PersistentVolumeClaim"
  type        = string
  default     = "pvc-blob"
}

variable "namespace" {
  description = "Namespace where the PVC will be created"
  type        = string
  default     = "default"
}

variable "storage_size" {
  description = "Size of the storage in Gi"
  type        = string
  default     = "10Gi"
}

variable "storage_class_name" {
  description = "Name of the storage class"
  type        = string
  default     = "azureblob-fuse-premium"
}

variable "volume_name" {
  description = "Name of the PersistentVolume to bind to"
  type        = string
  default     = "pv-blob"
}

variable "access_modes" {
  description = "Access modes for the PVC"
  type        = list(string)
  default     = ["ReadWriteMany"]
  
  validation {
    condition     = length(var.access_modes) > 0
    error_message = "At least one access mode must be specified"
  }
}