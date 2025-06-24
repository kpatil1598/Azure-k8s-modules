variable "location" {}
variable "rg_name" {}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "aks_name" {}
variable "aks_rg" {}

variable "appgw_subnet_id" {
  description = "Subnet ID where Application Gateway should be deployed"
}
