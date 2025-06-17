output "karpenter_namespace" {
  value = kubernetes_namespace.karpenter.metadata[0].name
}
