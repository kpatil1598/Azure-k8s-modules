variable "location" {}
variable "resource_group_name" {}
variable "node_resource_group_name" {}
variable "node_resource_group_id" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "cluster_name" {}
variable "cluster_endpoint" {}
variable "namespace" {
  default = "karpenter"
}
variable "service_account_name" {
  default = "karpenter"
}
variable "oidc_issuer_url" {}
