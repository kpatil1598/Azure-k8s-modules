module "subscription" {
  source = "C:\\Users\\chava\\Desktop\\k8s-module\\modules\\subscription"
    billing_account_name = var.billing_account_name
    billing_profile_name = var.billing_profile_name
    invoice_section_name = var.invoice_section_name
    subscription_name   = var.subscription_name
}
