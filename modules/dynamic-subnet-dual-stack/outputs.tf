output "private_subnet_cidrs" {
  value = [for s in local.private_subnets : s.cidr]
}

output "public_subnet_cidrs" {
  value = [for s in local.public_subnets : s.cidr]
}
output "private_subnet_ipv6_cidrs" {
  value = [for s in local.private_subnets : s.ipv6_cidr if s.ipv6_cidr != null]
}
output "public_subnet_ipv6_cidrs" {
  value = [for s in local.public_subnets : s.ipv6_cidr if s.ipv6_cidr != null]
}
output "subnet_ids" {
  description = "IDs of all created subnets"
  value       = { for k, subnet in azurerm_subnet.this : k => subnet.id }
}
# output "private_subnet_ids" {
#   description = "IDs of all private subnets"
#   value       = { for k, subnet in azurerm_subnet.this : k => subnet.id if subnet.name in local.private_subnets[*].name }
# }
output "private_subnet_ids" {
  value = {
    for k, v in azurerm_subnet.this :
    k => v.id if local.subnet_map[k].type == "private"
  }
}

output "public_subnet_ids" {
  value = {
    for k, v in azurerm_subnet.this :
    k => v.id if local.subnet_map[k].type == "public"
  }
}
