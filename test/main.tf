terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.2.0"
}
provider "azurerm" {
    features {}
}
# Resource group used to hold DNS zones for testing
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}
# 1) Client parent zone: abc.example.com
resource "azurerm_dns_zone" "abc" {
  name                = "abc.${var.root_domain}"
  resource_group_name = azurerm_resource_group.rg.name
}
# 2) Child zones under abc: dam, dam-lb, site-nyc (each as separate zones)
resource "azurerm_dns_zone" "dam" {
  name                = "dam.abc.${var.root_domain}"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_dns_zone" "dam_lb" {
  name                = "dam-lb.abc.${var.root_domain}"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_dns_zone" "site_nyc" {
  name                = "site-nyc.abc.${var.root_domain}"
  resource_group_name = azurerm_resource_group.rg.name
}
# 3) Infra zones in same subscription for testing
resource "azurerm_dns_zone" "infra" {
  name                = "infraempheral.${var.root_domain}"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_dns_zone" "infra_site" {
  name                = "site-nyc.cortex-a.infraempheral.${var.root_domain}"
  resource_group_name = azurerm_resource_group.rg.name
}
# -----------------------
# Delegation (NS records)
# -----------------------
# Delegate "dam" from abc -> dam.abc.example.com
resource "azurerm_dns_ns_record" "abc_to_dam" {
  name                = "dam"                              # subdomain label in parent zone
  zone_name           = azurerm_dns_zone.abc.name
  resource_group_name = azurerm_dns_zone.abc.resource_group_name
  ttl                 = 3600
  records             = azurerm_dns_zone.dam.name_servers
}
# Delegate "dam-lb" from abc -> dam-lb.abc.example.com
resource "azurerm_dns_ns_record" "abc_to_dam_lb" {
  name                = "dam-lb"
  zone_name           = azurerm_dns_zone.abc.name
  resource_group_name = azurerm_dns_zone.abc.resource_group_name
  ttl                 = 3600
  records             = azurerm_dns_zone.dam_lb.name_servers
}
# Delegate "site-nyc" from abc -> site-nyc.abc.example.com
resource "azurerm_dns_ns_record" "abc_to_site_nyc" {
  name                = "site-nyc"
  zone_name           = azurerm_dns_zone.abc.name
  resource_group_name = azurerm_dns_zone.abc.resource_group_name
  ttl                 = 3600
  records             = azurerm_dns_zone.site_nyc.name_servers
}
# If you wanted to delegate a subdomain under infra, delegate similarly:
# Delegate "site-nyc.cortex-a" under infraempheral -> infra_site zone
resource "azurerm_dns_ns_record" "infra_to_infra_site" {
  name                = "site-nyc.cortex-a"
  zone_name           = azurerm_dns_zone.infra.name
  resource_group_name = azurerm_dns_zone.infra.resource_group_name
  ttl                 = 3600
  records             = azurerm_dns_zone.infra_site.name_servers
}
# -----------------------
# Example records inside child zones
# -----------------------
# NOTE: you can't put a CNAME at zone apex. See notes below.
# In dam.abc.example.com zone: create a CNAME record "to-dam-lb" mapping a label to the lb zone
resource "azurerm_dns_cname_record" "dam_to_dam_lb" {
  name                = "to-dam-lb"    # example label inside dam zone
  zone_name           = azurerm_dns_zone.dam.name
  resource_group_name = azurerm_dns_zone.dam.resource_group_name
  ttl                 = 300
  record              = "some-record.dam-lb.abc.${var.root_domain}" # for demo; typically you'd point to specific host in dam-lb zone
}
# In dam-lb.abc... create CNAME pointing to site-nyc.abc...
resource "azurerm_dns_cname_record" "dam_lb_to_site" {
  name                = "to-site"
  zone_name           = azurerm_dns_zone.dam_lb.name
  resource_group_name = azurerm_dns_zone.dam_lb.resource_group_name
  ttl                 = 300
  record              = "some-host.site-nyc.abc.${var.root_domain}"
}
# -----------------------
# Final infra A record (in infra_site) pointing to AKS ingress IP
# -----------------------
resource "azurerm_dns_a_record" "infra_site_a" {
  name                = "@" # creates the A record at the apex of infra_site zone
  zone_name           = azurerm_dns_zone.infra_site.name
  resource_group_name = azurerm_dns_zone.infra_site.resource_group_name
  ttl                 = 300
  records             = [var.aks_ingress_ip]
}