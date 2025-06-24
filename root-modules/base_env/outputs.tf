output "private_subnet_cidrs" {
  value = module.networking.private_subnet_cidrs
}
output "public_subnet_cidrs" {
  value = module.networking.public_subnet_cidrs
}
output "private_subnet_ipv6_cidrs" {
  value = module.networking.private_subnet_ipv6_cidrs
}
output "public_subnet_ipv6_cidrs" {
  value = module.networking.public_subnet_ipv6_cidrs
}