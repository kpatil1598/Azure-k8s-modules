variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the resources"
}

variable "vnet_cidrs" {
  type        = list(string)
  description = <<EOT
List of CIDRs for the virtual network. 
- First CIDR must be IPv4 (e.g., '10.0.0.0/16')
- Second CIDR (optional) is IPv6 (e.g., 'fd00:abcd::/48') for dual-stack
EOT
}

 variable "availability_zones" {
   type        = list(string)
   description = "List of availability zones for subnet distribution"
 }

variable "number_private_subnet" {
  type        = number
  description = "Number of private subnets to create"
}

variable "number_public_subnet" {
  type        = number
  description = "Number of public subnets to create"
}

variable "ipv4_subnet_mask_private" {
  type        = number
  description = "Subnet mask (CIDR bits) for IPv4 private subnets (e.g., 24 for /24)"
}

variable "ipv4_subnet_mask_public" {
  type        = number
  description = "Subnet mask (CIDR bits) for IPv4 public subnets (e.g., 24 for /24)"
}

variable "ipv6_subnet_mask_private" {
  type        = number
  default     = 64
  description = "Subnet mask (CIDR bits) for IPv6 private subnets (default /64)"
}

variable "ipv6_subnet_mask_public" {
  type        = number
  default     = 64
  description = "Subnet mask (CIDR bits) for IPv6 public subnets (default /64)"
}

variable "enable_aks_delegation" {
  type        = bool
  default     = false
  description = "Enable subnet delegation for AKS"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}
