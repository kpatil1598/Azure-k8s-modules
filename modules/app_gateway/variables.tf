variable "name" {
  type        = string
  description = "Name of the Application Gateway"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group in which to deploy"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "is_public" {
  type        = bool
  description = "Should the App Gateway be public or private?"
  default     = true
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the App Gateway"
}

variable "private_ip_address" {
  type        = string
  description = "Static private IP (required if is_public = false)"
  default     = null
}

variable "capacity" {
  type        = number
  description = "Instance count for the App Gateway"
  default     = 2
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
