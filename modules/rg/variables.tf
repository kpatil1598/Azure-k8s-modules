variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the resource group will be created"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags to assign to the resource group"
  type        = map(string)
  default     = {}
}
