locals {
  # Extract base mask from CIDR
  cidr_match_ipv4 = regex("\\/(\\d+)$", var.vnet_cidrs[0])
  base_mask_ipv4  = length(local.cidr_match_ipv4) > 0 ? tonumber(local.cidr_match_ipv4[0]) : null

  # Optional: Extract IPv6 base mask
  cidr_match_ipv6 = length(var.vnet_cidrs) > 1 ? regex("\\/(\\d+)$", var.vnet_cidrs[1]) : []
  base_mask_ipv6  = length(local.cidr_match_ipv6) > 0 ? tonumber(local.cidr_match_ipv6[0]) : null

  # Calculate additional bits to create subnets
  additional_bits_private_ipv4 = var.ipv4_subnet_mask_private - local.base_mask_ipv4
  additional_bits_public_ipv4  = var.ipv4_subnet_mask_public  - local.base_mask_ipv4

  additional_bits_private_ipv6 = local.base_mask_ipv6 != null ? var.ipv6_subnet_mask_private - local.base_mask_ipv6 : null
  additional_bits_public_ipv6  = local.base_mask_ipv6 != null ? var.ipv6_subnet_mask_public  - local.base_mask_ipv6 : null

  private_subnets = [
    for i in range(var.number_private_subnet) : {
      name              = "private-subnet-${i + 1}"
      type              = "private"
      cidr              = cidrsubnet(var.vnet_cidrs[0], local.additional_bits_private_ipv4, i)
      ipv6_cidr         = local.base_mask_ipv6 != null ? cidrsubnet(var.vnet_cidrs[1], local.additional_bits_private_ipv6, i) : null
      availability_zone = var.availability_zones[i % length(var.availability_zones)]
    }
  ]

  public_subnets = [
    for i in range(var.number_public_subnet) : {
      name              = "public-subnet-${i + 1}"
      type              = "public"
      cidr              = cidrsubnet(var.vnet_cidrs[0], local.additional_bits_public_ipv4, var.number_private_subnet + i)
      ipv6_cidr         = local.base_mask_ipv6 != null ? cidrsubnet(var.vnet_cidrs[1], local.additional_bits_public_ipv6, var.number_private_subnet + i) : null
      availability_zone = var.availability_zones[i % length(var.availability_zones)]
    }
  ]

  all_subnets = concat(local.private_subnets, local.public_subnets)
}

resource "azurerm_virtual_network" "this" {
  name                = "aks-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_cidrs
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each             = { for s in local.all_subnets : s.name => s }
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.cidr]

  # Uncomment to enable AKS subnet delegation
  # delegation {
  #   name = "aks_delegation"
  #   service_delegation {
  #     name    = "Microsoft.ContainerService/managedClusters"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  #   }
  # }
}
