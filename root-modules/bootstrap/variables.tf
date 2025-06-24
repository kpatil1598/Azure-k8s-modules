variable "resource_group_name" {
  type        = string
  description = "Name of the resource group for state storage"
    default     = "tfstate-rg"  
}
variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region for the resource group and storage account"
}
variable "account_code" {
  type        = string
  description = "Unique code for the account, used in resource names"
}
variable "location" {
  type        = string
  default     = "eus"
  description = "Short code for the Azure region, used in resource names"
}