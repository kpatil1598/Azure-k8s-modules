# variable "internal_ipv4" {
#     type        = string
#     description = "Internal IPv4 address for the NGINX Ingress Controller"
  
# }
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resources"
}
variable "location" {
  type        = string
  description = "Location for the resources"
}
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}