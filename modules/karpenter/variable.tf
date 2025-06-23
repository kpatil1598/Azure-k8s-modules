variable "namespace" {
  description = "Namespace for Karpenter"
  type        = string
  default     = "karpenter"
}

variable "chart_version" {
  description = "Helm chart version"
  type        = string
  default     = "v0.36.1" # update as needed
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the AKS cluster"
  type        = string
}

variable "karpenter_irsa_role_arn" {
  description = "IAM role ARN for the Karpenter controller"
  type        = string
}

variable "service_account_name" {
  description = "Name of the service account"
  type        = string
  default     = "karpenter"
}
