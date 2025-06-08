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