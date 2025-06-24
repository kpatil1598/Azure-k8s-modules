# locals {
#   base_mask_ipv4 = tonumber(regex("\\/(\\d+)$", var.vnet_cidrs[0])[0]) # 20
#   base_mask_ipv6 = tonumber(regex("\\/(\\d+)$", var.vnet_cidrs[1])[0]) # 48

#   private_ipv4_bits = var.ipv4_subnet_mask_private - local.base_mask_ipv4 # 23-20=3
#   public_ipv4_bits  = var.ipv4_subnet_mask_public  - local.base_mask_ipv4 # 26-20=6
#   ipv6_bits         = var.ipv6_subnet_mask_private - local.base_mask_ipv6 # 64-48=16

#   max_private_subnets         = pow(2, local.private_ipv4_bits)
#   start_index_for_public_ipv4 = local.max_private_subnets * pow(2, local.public_ipv4_bits - local.private_ipv4_bits)

#   private_subnets = [
#     for i in range(var.number_private_subnet) : {
#       name      = "private-subnet-${i + 1}",
#       cidr      = cidrsubnet(var.vnet_cidrs[0], local.private_ipv4_bits, i),
#       ipv6_cidr = cidrsubnet(var.vnet_cidrs[1], local.ipv6_bits, i),
#       az        = var.availability_zones[i % length(var.availability_zones)]
#     }
#   ]

#   public_subnets = [
#     for i in range(var.number_public_subnet) : {
#       name      = "public-subnet-${i + 1}",
#       cidr      = cidrsubnet(var.vnet_cidrs[0], local.public_ipv4_bits, local.start_index_for_public_ipv4 + i),
#       ipv6_cidr = cidrsubnet(var.vnet_cidrs[1], local.ipv6_bits, local.max_private_subnets + i),
#       az        = var.availability_zones[i % length(var.availability_zones)]
#     }
#   ]

#   all_subnets = concat(local.private_subnets, local.public_subnets)
# }

locals {
  base_mask_ipv4 = tonumber(regex("\\/(\\d+)$", var.vnet_cidrs[0])[0])
  base_mask_ipv6 = tonumber(regex("\\/(\\d+)$", var.vnet_cidrs[1])[0])

  private_ipv4_bits = var.ipv4_subnet_mask_private - local.base_mask_ipv4
  public_ipv4_bits  = var.ipv4_subnet_mask_public  - local.base_mask_ipv4
  ipv6_bits         = var.ipv6_subnet_mask_private - local.base_mask_ipv6

  # Total available subnets of /26 in base /20
  total_available_subnets = pow(2, local.public_ipv4_bits)

  # /26 blocks consumed by private /23s
  used_by_private_subnets = var.number_private_subnet * pow(2, local.public_ipv4_bits - local.private_ipv4_bits)

  # Start public subnets after private consumption
  start_index_for_public_ipv4 = local.used_by_private_subnets

  private_subnets = [
    for i in range(var.number_private_subnet) : {
      name      = "private-subnet-${i + 1}"
      cidr      = cidrsubnet(var.vnet_cidrs[0], local.private_ipv4_bits, i)
      ipv6_cidr = cidrsubnet(var.vnet_cidrs[1], local.ipv6_bits, i)
      az        = var.availability_zones[i % length(var.availability_zones)]
    }
  ]

  public_subnets = [
    for i in range(var.number_public_subnet) : {
      name      = "public-subnet-${i + 1}"
      cidr      = cidrsubnet(var.vnet_cidrs[0], local.public_ipv4_bits, local.start_index_for_public_ipv4 + i)
      ipv6_cidr = cidrsubnet(var.vnet_cidrs[1], local.ipv6_bits, local.used_by_private_subnets + i)
      az        = var.availability_zones[i % length(var.availability_zones)]
    }
  ]

  all_subnets = concat(local.private_subnets, local.public_subnets)
  subnet_map = {
    for subnet in local.all_subnets :
    subnet.name => {
      cidr      = subnet.cidr
      ipv6_cidr = subnet.ipv6_cidr
      az        = subnet.az
      type      = substr(subnet.name, 0, 7) == "private" ? "private" : "public"
    }
  }
}
