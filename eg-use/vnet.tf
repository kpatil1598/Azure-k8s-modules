# module "vnet_dualstack" {
#   source = "./modules/vnet"

#   resource_group_name = "rg-dualstack"
#   location            = "eastus"

#   vnet_name           = "vnet-dual"
#   vnet_address_space  = ["10.0.0.0/16"]
#   vnet_ipv6_space     = ["fd00:db8:abcd::/48"]

#   public_subnet_name        = "public-subnet"
#   public_subnet_prefix      = "10.0.1.0/24"
#   public_subnet_ipv6_prefix = "fd00:db8:abcd::/64"

#   private_subnet_prefix     = "private-subnet"
#   private_subnet_prefixes   = [
#     "10.0.2.0/24",
#     "10.0.3.0/24",
#     "10.0.4.0/24"
#   ]
#   private_subnet_ipv6_prefixes = [
#     "fd00:db8:abcd:1::/64",
#     "fd00:db8:abcd:2::/64",
#     "fd00:db8:abcd:3::/64"
#   ]
# }
# module "public_routing" {
#   source              = "./modules/routing"
#   name                = "public-rt"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = azurerm_subnet.public.id
#   next_hop_type       = "Internet"
# }

# module "private_routing_1" {
#   source              = "./modules/routing"
#   name                = "private-rt-1"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = azurerm_subnet.private[0].id
#   next_hop_type       = "VirtualAppliance"  # or "None" if handled by NAT Gateway directly
#   next_hop_ip         = "10.0.0.4" # optional if VirtualAppliance
#   create_default_route = false     # skip route if NAT Gateway handles outbound
# }
