variable "billing_account_name" {
  type        = string
  description = "MCA billing account name (GUID:GUID_DATE)"
}
variable "billing_profile_name" {
  type        = string
  description = "Billing profile under MCA account"
}
variable "invoice_section_name" {
  type        = string
  description = "Invoice section to link subscription"
}
variable "subscription_name" {
  type        = string
  description = "Name for the new subscription"
}
