resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = kubernetes_namespace.karpenter.metadata[0].name
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.chart_version

  values = [
    yamlencode({
      settings = {
        clusterName = var.cluster_name
        clusterEndpoint = var.cluster_endpoint
      }

      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = var.karpenter_irsa_role_arn
        }
        name = var.service_account_name
        create = true
      }
    })
  ]

  depends_on = [kubernetes_namespace.karpenter]
}
