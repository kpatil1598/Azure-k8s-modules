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
  default     = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkltdGhERHkyMF80M3FmRk1YOXBzSDE2UGdVUkF5NlZidHpyaTM5ZUhITTAifQ.eyJhdWQiOlsiaHR0cHM6Ly9lYXN0dXMub2ljLnByb2QtYWtzLmF6dXJlLmNvbS8zMjQ2MjgxMC05NzNkLTRkOWEtYTE5NS1mMDFiMTM1YWU3YjUvNjJjODQ4ZmQtOGU1OC00YTg1LTkwOGMtNzQ5Zjc0ZjBiOGE5LyIsImh0dHBzOi8vYWtzY2x1c3Rlci1hYWt5Z25qMy5oY3AuZWFzdHVzLmF6bWs4cy5pbyIsIlwiYWtzY2x1c3Rlci1hYWt5Z25qMy5oY3AuZWFzdHVzLmF6bWs4cy5pb1wiIl0sImV4cCI6MTc1MDI4MzE5MywiaWF0IjoxNzUwMjc5NTkzLCJpc3MiOiJodHRwczovL2Vhc3R1cy5vaWMucHJvZC1ha3MuYXp1cmUuY29tLzMyNDYyODEwLTk3M2QtNGQ5YS1hMTk1LWYwMWIxMzVhZTdiNS82MmM4NDhmZC04ZTU4LTRhODUtOTA4Yy03NDlmNzRmMGI4YTkvIiwianRpIjoiNGI5YjliYjMtZjQ0OC00NDM0LThjZjktOGFlNmQxYzkwYjEwIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJrYXJwZW50ZXIiLCJ1aWQiOiIwMGQ1NGNhMy1iMWRhLTRlZTMtYjg2OC1jNDc2YzIyYjNhZDgifX0sIm5iZiI6MTc1MDI3OTU5Mywic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmthcnBlbnRlciJ9.QhV0VsbzEshffpe4LNkSgXcUoy-vEELUTwpoqwOn6wthiKoZRpyLPFXVa6n3Sia0Mn3kigY6ynY92n8wWaGHZqSQWGFoZ0jstX_M4-Gv69RH5_OjCj7h4_IO-IZE5jHNxvxuvNpyqCp1CpRoAHg7HF_FEdflwvS6YSFtJoz1HZVBmOkbXsE-iS9hjPKqrUAYbNx6YpcF4kBrTq1zxWeF55WeJ8Fx-0JowkNqRMkRHBopwwYvjJ659DxUPx_vgxeh2AC_YYaWfdJf3JOu7OCoxFimNwh99L9Y4YGjS02ROT7tdqqDa_T-MPwXsGD6ewFiJuyhq87EaxX2GsM_qA2qdZ-PK0FbVLQ1baHAW4_n-iuaXqtDqduPfU0D18QfevH-dOpszUDleTKMO4sOJM3-JiJ6W3TyyaIL-7X-wSW39Dj65V2Ia5-_ZcepHgTSK--gKVu9I8Z9OaMpBLYTnHyAlAlxqkyxyn9I9irhHkSJYsZqu1fxMyDBsghcor3jrO-ZjjVR0PX_wBPQiSrykxXrrC-sga3TsFjdRL3jZcqFid62jThbXr6tYTyuuIdjOVvryFpaa7njX4DypVBjs9uO__HFKQQEh5g0cS3W-J43YLNbGXWnsaOXfSmL_LfVg9FPRcPw6xYAGAy5WQSN7c2Z9Vl52-XRXXmcXsiETEepOgY"
}
variable "node_resource_group_id" {
  description = "The resource group where the AKS node resources are managed"
  type        = string
  default     = null
  
}
# variable "node_resource_group_id" {
#   description = "The resource group ID where the AKS node resources are managed"
#   type        = string
#   default     = null
  
# }