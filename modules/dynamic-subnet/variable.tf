variable "vnet_cidr" {
  description = "Base CIDR block for the VNet"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where VNet and subnets are created"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones (strings, e.g. ['1','2','3'])"
  type        = list(string)
}

variable "subnets_per_az_count" {
  description = "Number of subnets per AZ"
  type        = number
  default     = 3
}

variable "number_private_subnet" {
  description = "Total number of private subnets"
  type        = number
}

variable "number_public_subnet" {
  description = "Total number of public subnets"
  type        = number
}

variable "ipv4_subnet_mask_private" {
  description = "Subnet mask length for private subnets"
  type        = number
}

variable "ipv4_subnet_mask_public" {
  description = "Subnet mask length for public subnets"
  type        = number
}
