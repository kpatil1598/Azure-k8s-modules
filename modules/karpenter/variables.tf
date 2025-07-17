variable "name" {
  description = "Prefix for resources created by the module"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "node_resource_group" {
  description = "Resource group managed by AKS for node resources"
  type        = string
}

variable "aks_api_server" {
  description = "API server URL for AKS"
  type        = string
}

variable "aks_host" {
  description = "AKS kube host"
  type        = string
}

variable "client_certificate" {
  description = "Client certificate for accessing AKS"
  type        = string
}

variable "client_key" {
  description = "Client key for accessing AKS"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Cluster CA cert for accessing AKS"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to place the new nodes"
  type        = string
}

variable "karpenter_version" {
  description = "Version of Karpenter Helm chart"
  type        = string
  default     = "0.7.0"
}

variable "karpenter_provider_version" {
  description = "Version of Azure Karpenter provider Helm chart"
  type        = string
  default     = "0.0.17"
}
variable "issuer_url" {
  description = "Issuer URL for the Azure Workload Identity"
  type        = string

}
variable "kubelet_bootstrap_token" {
  description = "Kubelet bootstrap token for Karpenter"
  type        = string
  default     = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjB4OEU1TUVtSUp2bmJEM2ladGJmemUxenJQTnFyN3RQd2ZVeTctV05yRW8ifQ.eyJhdWQiOlsiaHR0cHM6Ly9lYXN0dXMub2ljLnByb2QtYWtzLmF6dXJlLmNvbS8xNjU1MWZmMy00YmIyLTQ0YzctOGI0Yi01YTBkMTYyZTI0ZWYvOTVmZThkNzMtYzQxMC00MzZhLTg4OGYtNmYxMTVjY2QzNDJiLyIsImh0dHBzOi8vYWtzY2x1c3Rlci10d2F1d3IzNC5oY3AuZWFzdHVzLmF6bWs4cy5pbyIsIlwiYWtzY2x1c3Rlci10d2F1d3IzNC5oY3AuZWFzdHVzLmF6bWs4cy5pb1wiIl0sImV4cCI6MTc1MTIxNjQwMSwiaWF0IjoxNzUxMTMwMDAxLCJpc3MiOiJodHRwczovL2Vhc3R1cy5vaWMucHJvZC1ha3MuYXp1cmUuY29tLzE2NTUxZmYzLTRiYjItNDRjNy04YjRiLTVhMGQxNjJlMjRlZi85NWZlOGQ3My1jNDEwLTQzNmEtODg4Zi02ZjExNWNjZDM0MmIvIiwianRpIjoiZWMxZTJlYzMtOWRhOC00NDk4LWI1ZjYtZjNlYTFlZWJiNjk5Iiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJrYXJwZW50ZXIiLCJ1aWQiOiJlNWJlZGE3Mi1jM2RhLTRmZmItYjc0Mi00ZGE0ODUxYmEwY2UifX0sIm5iZiI6MTc1MTEzMDAwMSwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmthcnBlbnRlciJ9.iikabGgnxmy6coUbHhE0BGtoPqZM6gljDAIyFfPqEx_rg63hCCSJfMzS9SoQny3cXNUYVHZzsh2--Yabve_-n9DqEUxkkesSzbX-ElUeEUtRnteS5_Qtb7GkyJjj3S31SZtw0rxepCNlS5FWi05IEw8HF_3iryOq63FtaJxriCpTuGGJtVeQF2b6hLYAI9Lab95zAWmP1NyoH-Gz0IvhkOrhs7e7jRUs8TJqMaoUGi71iBq4qCVrKNiewvTPgyI1zDhhJU8Vb2j9pRsRVujf2JpEawJMj2Z2BTC43JIAzc0-Jo9uBkGSRXTYdVVaJ3KaGIxxvOnXuKUBL_RM4oKduIqVJrtQGfQsAdII6LpUbKhwCS-KQLF1itAwtQ_GNMEhy-5NYGvlikYNxJY-rOwoYsrT7HQnqQclO0_7AeAA_NaevjO-uX-1-yRMDmCj-KH0UvRRRXoR0nCz4F5M8pUlrTmquzFYFgteK2D8h9A3scowHzh3oNzAPxBN03qThmtFEkJCMSdjf3GDaP-O3sQqO0XK92j_Tio0PnossLScWSMG1mvYR33W4Bi2MRrKf5NS9Sv4wgpM2dLQZcKxpwZ7GaM0drW1GpL4NHAhEAae41n7UewFnGZ6Nm9z74o7VQJ32cpRtbmurO4RWX7uAOGzJ7PGMtRcSG6zYb8AlRkqd2M"
}

variable "ssh_public_key" {
  description = "SSH public key for accessing the VMs created by Karpenter"
  type        = string
  default     = ""
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "aks-vnet"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "private-subnet-1"
}