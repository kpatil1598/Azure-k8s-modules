variable "name" {
  type        = string
  description = "Prefix for naming"
}

variable "location" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "appgw_id" {
  type        = string
  description = "Resource ID of the Application Gateway"
}

variable "appgw_rg_scope" {
  type        = string
  description = "Scope of the App Gateway's resource group"
}
