resource "azurerm_public_ip" "appgw" {
  count               = var.is_public ? 1 : 0
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendIP"
    public_ip_address_id = var.is_public ? azurerm_public_ip.appgw[0].id : null
    private_ip_address   = var.is_public ? null : var.private_ip_address
    #subnet_id            = var.subnet_id
    
    #private_ip_allocation = var.is_public ? null : "Static"
  }

  backend_address_pool {
    name = "defaultbackendpool"
  }

  backend_http_settings {
    name                  = "defaultbackendsetting"
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout       = 30
  }

  http_listener {
    name                           = "defaultlistener"
    frontend_ip_configuration_name = "frontendIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "defaultlistener"
    backend_address_pool_name  = "defaultbackendpool"
    backend_http_settings_name = "defaultbackendsetting"
    priority = 100
  }

  tags = var.tags
}
