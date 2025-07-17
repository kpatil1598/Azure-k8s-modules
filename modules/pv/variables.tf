variable "pv_name" {
  description = "Name of the PersistentVolume"
  type        = string
  default     = "pv-blob"
}

variable "namespace" {
  description = "Namespace where the PV will be created"
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

variable "volume_handle" {
  description = "Unique volume handle in format account-name_container-name"
  type        = string
}

variable "container_name" {
  description = "Name of the Azure Blob container"
  type        = string
}

variable "secret_name" {
  description = "Name of the secret containing storage credentials"
  type        = string
  default     = "azure-secret"
}

variable "mount_options" {
  description = "Mount options for the blob storage"
  type        = list(string)
  default     = ["-o allow_other", "--file-cache-timeout-in-seconds=120"]
}

variable "reclaim_policy" {
  description = "PersistentVolume reclaim policy"
  type        = string
  default     = "Retain"
  validation {
    condition     = contains(["Retain", "Delete", "Recycle"], var.reclaim_policy)
    error_message = "Reclaim policy must be one of: Retain, Delete, Recycle"
  }
}