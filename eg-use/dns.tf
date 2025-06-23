module "ingress_dns" {
  source = "./modules/ingress_dns"

  dns_zone_name           = "example.com"
  dns_zone_resource_group = "dns-rg"
  dns_record_name         = "app"
}
