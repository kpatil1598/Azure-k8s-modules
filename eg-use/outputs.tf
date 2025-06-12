# output "private_subnet_cidrs" {
#   value = module.networking.private_subnet_cidrs
# }
# output "public_subnet_cidrs" {
#   value = module.networking.public_subnet_cidrs
# }
# output "private_subnet_ipv6_cidrs" {
#   value = module.networking.private_subnet_ipv6_cidrs
# }
# output "public_subnet_ipv6_cidrs" {
#   value = module.networking.public_subnet_ipv6_cidrs
# }
output "name" {
  value = module.resource_group.resource_group_name
  
}
# output "subnet_ids" {
#   description = "IDs of all created subnets"
#   value       = module.networking.subnet_ids
#   }
output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}
output "kube_config_raw" {
  description = "Raw kubeconfig to connect to AKS cluster"
  value       = module.aks.kube_config_raw
  sensitive   = true
}