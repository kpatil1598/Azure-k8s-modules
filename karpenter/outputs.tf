output "karpenter_release_name" {
  value = helm_release.karpenter.name
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
