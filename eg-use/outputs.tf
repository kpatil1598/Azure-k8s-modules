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
output "name" {
  value = module.networking.resource_group_name

}
# output "subnet_ids" {
#   description = "IDs of all created subnets"
#   value       = module.networking.subnet_ids
#   }
output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}
output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
  
}
output "kube_config_raw" {
  description = "Raw kubeconfig to connect to AKS cluster"
  value       = module.aks.kube_config_raw
  sensitive   = true
}
# output "gateway_id" {
#   description = "ID of the Application Gateway"
#   value       = module.app_gateway.id
  
# }
output "issuer_url" {
  description = "Issuer URL for the AKS cluster"
  value       = module.aks  
  sensitive = true
}
output "principal_id" {
  description = "Managed identity for AKS cluster"
  value       = module.aks.identity_principal_id  
}
# output "identity_id" {
#   description = "Managed identity ID for AKS cluster"
#   value       = module.aks.identity_id  
  
# }