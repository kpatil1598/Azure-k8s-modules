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
