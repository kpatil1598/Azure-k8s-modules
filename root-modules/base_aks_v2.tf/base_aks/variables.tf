variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "cluster_name" { type = string }
variable "dns_prefix" { type = string }
variable "kubernetes_version" { type = string }
variable "vnet_subnet_id" { type = string } # from vnet module

variable "default_node_pool" {
  type = object({
    name       = string
    vm_size    = string
    node_count = number
    zones      = optional(list(number), null)
  })
  default = {
    name       = "agentpool"
    vm_size    = "Standard_DS2_v2"
    node_count = 2
    zones      = null
  }
}

variable "nodepools" {
  type = map(object({
    name                  = string
    vm_size               = string
    min_count             = number
    max_count             = number
    enable_auto_scaling   = bool
    vnet_subnet_id        = string
    enable_node_public_ip = bool
    zones                 = optional(list(number), null)
    tags                  = optional(map(string), {})
    node_labels           = optional(map(string), {})
  }))
  default = {}
}
variable "gateway_id" {
  type        = string
  description = "ID of the Application Gateway to use for ingress"
  default     = null
}
variable "enable_auto_scaling" {
  type        = bool
  description = "Enable auto-scaling for the default node pool"
  default     = true
}
variable "pod_subnet_id" {
  type        = string
  description = "Subnet ID for the pod network"
  default     = null
}
variable "ats_node_pool_enabled" {
  type        = bool
  description = "Enable the ATS node pool"
  default     = false 
}