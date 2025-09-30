variable "location" {
  type    = string
  default = "eastus"
}
variable "resource_group" {
  type    = string
  default = "rg-dns-test"
}
variable "aks_ingress_ip" {
  type    = string
  default = "20.50.60.70" # replace with your test AKS ingress IP
}
variable "root_domain" {
  type    = string
  default = "example.com"
}
