##############################################
# Variables (shape kept close to your inputs)
##############################################
variable "email_configuration" {
  type = object({
    enabled         = bool
    account_domains = list(string) # e.g., ["example.com", "example.org"]
  })
}

variable "client_code" {
  type = string
  # e.g., "orangelogic" -> creates subdomain like orangelogic.example.com (same as your SES pattern)
}

# ACS-generated DNS values must be copied from the portal/API per domain (see notes below).
# Provide them here (per domain) once created by Azure.
variable "acs_dns_records" {
  # Map key = base domain from account_domains
  # DKIM targets are ACS-provided CNAME targets.
  type = map(object({
    # The “owner” names below are fixed (selector1/selector2); you supply the ACS target values.
    dkim1_target      = string # e.g., "selector1-your-domain-with-dashes._domainkey.<tenant-part>-v1.dkim.mail.microsoft"
    dkim2_target      = string # e.g., "selector2-your-domain-with-dashes._domainkey.<tenant-part>-v1.dkim.mail.microsoft"
    spf_value         = string # e.g., "v=spf1 include:spf.protection.outlook.com -all"
    verify_txt_name   = string # e.g., "asuid.orangelogic" or the exact name Azure shows for verification
    verify_txt_value  = string # Azure shows a GUID-like value for TXT domain verification
  }))
}

##############################################
# Resource Group (use existing if you have one)
##############################################
resource "azurerm_resource_group" "email_rg" {
  name     = "rg-email-shared"
  location = "East US"
}

##############################################
# ACS (base) + ACS Email Service
##############################################
resource "azurerm_communication_service" "acs" {
  name                = "acs-shared-${var.client_code}"
  resource_group_name = azurerm_resource_group.email_rg.name
  data_location       = "United States"
}

resource "azurerm_email_communication_service" "email" {
  name                = "acs-email-${var.client_code}"
  resource_group_name = azurerm_resource_group.email_rg.name
  data_location       = "United States"
}

##############################################
# Per-domain provisioning (Customer-managed)
# Equivalent to "aws_ses_domain_identity" per domain
##############################################
# Build the subdomain like SES did: "<client_code>.<domain>"
locals {
  sending_domains = var.email_configuration.enabled ? [
    for d in var.email_configuration.account_domains : "${var.client_code}.${d}"
  ] : []
}

# Create ACS Email "Domain" resources for each sending domain
resource "azurerm_email_communication_service_domain" "domains" {
  for_each         = toset(local.sending_domains)
  name             = each.value                      # the sending domain (e.g., orangelogic.example.com)
  email_service_id = azurerm_email_communication_service.email.id
  domain_management = "CustomerManaged"              # you manage DNS in Azure DNS or elsewhere
}

##############################################
# Azure DNS (Route53 equivalent)
# We assume your public zones already exist in Azure DNS.
##############################################
# Data source to fetch the correct DNS zone for each *base* domain
# (Records will be created in that zone using names like "orangelogic" or "selector1._domainkey.orangelogic")
data "azurerm_dns_zone" "public_zones" {
  for_each = toset(var.email_configuration.account_domains)
  name     = each.value
  resource_group_name = "rg-dns-shared"              # <-- change to your DNS RG
}

# Split sending domain into "label"."basezone" for record names
locals {
  # Map base domain -> label (client_code)
  labels_by_domain = {
    for d in var.email_configuration.account_domains :
    d => var.client_code
  }
}

##############################################
# Domain ownership TXT (verification)
# (Equivalent to SES identity verification TXT step)
##############################################
resource "azurerm_dns_txt_record" "verify_txt" {
  for_each = var.email_configuration.enabled ? {
    for base in var.email_configuration.account_domains :
    base => base
  } : {}

  name                = var.acs_dns_records[each.key].verify_txt_name
  zone_name           = data.azurerm_dns_zone.public_zones[each.key].name
  resource_group_name = data.azurerm_dns_zone.public_zones[each.key].resource_group_name
  ttl                 = 300

  record {
    value = var.acs_dns_records[each.key].verify_txt_value
  }
}

##############################################
# SPF TXT (sender auth)
##############################################
resource "azurerm_dns_txt_record" "spf" {
  for_each = var.email_configuration.enabled ? {
    for base in var.email_configuration.account_domains :
    base => base
  } : {}

  # SPF is set on the *sending* domain (client_code.base)
  name                = local.labels_by_domain[each.key] # e.g., "orangelogic"
  zone_name           = data.azurerm_dns_zone.public_zones[each.key].name
  resource_group_name = data.azurerm_dns_zone.public_zones[each.key].resource_group_name
  ttl                 = 300

  record {
    value = var.acs_dns_records[each.key].spf_value
  }
}

##############################################
# DKIM CNAMEs (two selectors, like SES tokens)
# (Equivalent to "aws_ses_domain_dkim" + Route53 records)
##############################################
resource "azurerm_dns_cname_record" "dkim1" {
  for_each = var.email_configuration.enabled ? {
    for base in var.email_configuration.account_domains :
    base => base
  } : {}

  # selector1._domainkey.<sending-domain>
  name                = "selector1._domainkey.${local.labels_by_domain[each.key]}"
  zone_name           = data.azurerm_dns_zone.public_zones[each.key].name
  resource_group_name = data.azurerm_dns_zone.public_zones[each.key].resource_group_name
  ttl                 = 600
  record              = var.acs_dns_records[each.key].dkim1_target
}

resource "azurerm_dns_cname_record" "dkim2" {
  for_each = var.email_configuration.enabled ? {
    for base in var.email_configuration.account_domains :
    base => base
  } : {}

  # selector2._domainkey.<sending-domain>
  name                = "selector2._domainkey.${local.labels_by_domain[each.key]}"
  zone_name           = data.azurerm_dns_zone.public_zones[each.key].name
  resource_group_name = data.azurerm_dns_zone.public_zones[each.key].resource_group_name
  ttl                 = 600
  record              = var.acs_dns_records[each.key].dkim2_target
}

##############################################
# OPTIONAL: Link the domain to the ACS resource
# (Lets ACS use this domain for sending)
##############################################
resource "azurerm_communication_service_email_domain_association" "link" {
  for_each                  = toset(local.sending_domains)
  communication_service_id  = azurerm_communication_service.acs.id
  email_service_domain_id   = azurerm_email_communication_service_domain.domains[each.key].id
}
