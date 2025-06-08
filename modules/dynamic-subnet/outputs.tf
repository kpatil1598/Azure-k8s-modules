output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.this.name
}

output "subnets" {
  description = "List of all subnet details with name, cidr, type, and AZ"
  value = [
    for s in local.all_subnets : {
      name              = s.name
      cidr              = s.cidr
      availability_zone = s.availability_zone
      type              = s.type
      subnet_id         = azurerm_subnet.this[s.name].id
    }
  ]
}

output "private_subnets" {
  description = "List of private subnets with details"
  value = [
    for s in local.private_subnets : {
      name              = s.name
      cidr              = s.cidr
      availability_zone = s.availability_zone
      subnet_id         = azurerm_subnet.this[s.name].id
    }
  ]
}

output "public_subnets" {
  description = "List of public subnets with details"
  value = [
    for s in local.public_subnets : {
      name              = s.name
      cidr              = s.cidr
      availability_zone = s.availability_zone
      subnet_id         = azurerm_subnet.this[s.name].id
    }
  ]
}
