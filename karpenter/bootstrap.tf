resource "random_string" "bootstrap_token_id" {
  length  = 6
  upper   = false
  special = false
}

resource "random_string" "bootstrap_token_secret" {
  length  = 16
  upper   = false
  special = false
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  bootstrap_token_id     = random_string.bootstrap_token_id.result
  bootstrap_token_secret = random_string.bootstrap_token_secret.result
  bootstrap_token        = "${local.bootstrap_token_id}.${local.bootstrap_token_secret}"
}

resource "kubernetes_secret" "bootstrap_token" {
  metadata {
    name      = "bootstrap-token-${local.bootstrap_token_id}"
    namespace = "kube-system"
  }

  data = {
    "token-id"                        = local.bootstrap_token_id
    "token-secret"                    = local.bootstrap_token_secret
    "usage-bootstrap-authentication" = "true"
    "usage-bootstrap-signing"        = "true"
    "auth-extra-groups"              = "system:bootstrappers:karpenter-nodes"
    "expiration"                     = timeadd(timestamp(), "12h") # optional
  }

  type = "bootstrap.kubernetes.io/token"
}

output "kubelet_bootstrap_token" {
  value       = local.bootstrap_token
  description = "The Kubelet bootstrap token used for Karpenter"
  sensitive   = true
}

output "ssh_public_key" {
  value       = tls_private_key.ssh_key.public_key_openssh
  description = "SSH public key for access"
}

output "ssh_private_key" {
  value       = tls_private_key.ssh_key.private_key_pem
  description = "SSH private key for access"
  sensitive   = true
}
