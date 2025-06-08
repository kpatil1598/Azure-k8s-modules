variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vnet_name" {
  type        = string
  description = "Name of the VNet"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "IPv4 address space"
}

variable "vnet_ipv6_space" {
  type        = list(string)
  description = "IPv6 address space"
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the public subnet"
}

variable "public_subnet_prefix" {
  type        = string
  description = "IPv4 prefix for public subnet"
}

variable "public_subnet_ipv6_prefix" {
  type        = string
  description = "IPv6 prefix for public subnet"
}

variable "private_subnet_prefix" {
  type        = string
  default     = "private-subnet"
  description = "Name prefix for private subnets"
}

variable "private_subnet_prefixes" {
  type        = list(string)
  description = "List of IPv4 prefixes for private subnets"
}

variable "private_subnet_ipv6_prefixes" {
  type        = list(string)
  description = "List of IPv6 prefixes for private subnets"
}
variable "name" {
  description = "Name of the route table"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to associate the route table with"
  type        = string
}

variable "next_hop_type" {
  description = "The type of Azure hop the route uses: Internet, VirtualAppliance, etc."
  type        = string
}

variable "next_hop_ip" {
  description = "Next hop IP address if using VirtualAppliance"
  type        = string
  default     = null
}

variable "create_default_route" {
  description = "Whether to create a default route to the next hop"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}
