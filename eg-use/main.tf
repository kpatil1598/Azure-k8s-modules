
module "networking" {
  source                   = "..\\modules\\dynamic-subnet-dual-stack"
  resource_group_name      = module.resource_group.resource_group_name
  location                 = "eastus"
  vnet_cidrs               = ["10.0.0.0/20", "fd00::/48"]
  ipv4_subnet_mask_private = 23
  ipv4_subnet_mask_public  = 26
  ipv6_subnet_mask_private = 64
  ipv6_subnet_mask_public  = 64
  number_private_subnet    = 7
  number_public_subnet     = 3
  availability_zones       = ["1", "2", "3"]
  tags = {
    environment = "dev"
    owner       = "chinmay"
  }
}
