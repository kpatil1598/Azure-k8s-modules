resource "azurerm_dns_zone" "ingress_zone" {
  name                = var.dns_zone_name           # e.g., example.com
  resource_group_name = var.dns_zone_resource_group # e.g., dns-rg
}

resource "azurerm_dns_a_record" "ingress_dns" {
  name                = var.dns_record_name         # e.g., app -> app.example.com
  zone_name           = azurerm_dns_zone.ingress_zone.name
  resource_group_name = azurerm_dns_zone.ingress_zone.resource_group_name
  ttl                 = 300

  records = [
    data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
  ]
}



