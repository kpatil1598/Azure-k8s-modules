variable "cluster_name" {}
variable "cluster_endpoint" {}
variable "kubelet_bootstrap_token" {}
variable "ssh_public_key" {}
variable "network_plugin" {}
variable "network_plugin_mode" {}
variable "network_policy" {}
variable "vnet_subnet_id" {}
variable "vnet_guid" {}
variable "node_identities" {}
variable "subscription_id" {}
variable "location" {}
variable "mc_resource_group" {}
variable "service_account_name" {}
variable "client_id" {}
variable "log_level" { default = "info" }
variable "chart_version" { default = "0.7.3" }
