variable "billing_account_name" {
  type        = string
  description = "MCA billing account name (GUID:GUID_DATE)"
}

variable "billing_profile_name" {
  type        = string
  description = "Billing profile under MCA account"
}

variable "invoice_section_name" {
  type        = string
  description = "Invoice section to link subscription"
}

variable "subscription_name" {
  type        = string
  description = "Name for the new subscription"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group for state storage"
}

variable "location" {
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique name for the storage account"
}

variable "storage_container_name" {
  type        = string
  default     = "tfstate"
}
