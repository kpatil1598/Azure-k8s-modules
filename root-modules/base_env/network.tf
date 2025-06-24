module "base_env" {
  source                   = "C:\\Users\\chava\\Desktop\\k8s-module\\modules\\dynamic-subnet-dual-stack"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  vnet_cidrs               = var.vnet_cidrs
  ipv4_subnet_mask_private = var.ipv4_subnet_mask_private
  ipv4_subnet_mask_public  = var.ipv6_subnet_mask_public
  ipv6_subnet_mask_private = var.ipv6_subnet_mask_private
  ipv6_subnet_mask_public  = var.ipv6_subnet_mask_public
  number_private_subnet    = var.number_private_subnet
  number_public_subnet     = var.number_public_subnet
  availability_zones       = var.availability_zones
  tags                     = var.tags
}