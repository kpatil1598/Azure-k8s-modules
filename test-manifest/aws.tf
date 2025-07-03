resource "kubectl_manifest" "karpenter_base_template" {
  # See https://karpenter.sh/docs for version-specific structure (v0.37+ for EC2NodeClass)
  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name   = local.nodeclass_name.default
      labels = module.kube_labels.tags
    }
    spec = {
      amiFamily        = var.karpenter_default_nodepool_config.amiFamily
      amiSelectorTerms = var.karpenter_default_nodepool_config.amiSelectorTerms

      metadataOptions = {
        httpEndpoint            = "enabled"
        httpTokens              = "required"
        httpProtocolIPv6        = "disabled"
        httpPutResponseHopLimit = 1
      }

      role = element(split("/", var.eks.nodes_role_arn), 1)

      subnetSelectorTerms = [{
        tags = {
          "kubernetes.io/cluster/${var.eks.cluster_id}" = "shared"
          "orangelogic.com/net/subnet/type"             = "private"
        }
      }]

      securityGroupSelectorTerms = [{
        tags = {
          "kubernetes.io/cluster/${var.eks.cluster_id}" = "owned"
        }
      }]

      blockDeviceMappings = [{
        deviceName = "/dev/xvda"
        ebs = {
          volumeSize          = "20Gi"
          volumeType          = "gp3"
          deleteOnTermination = true
        }
      }]

      tags = merge(
        module.base_labels.tags,
        { "aml-modernized" = "aws-aml-orangelogic-cortex" },
        var.karpenter_default_nodepool_config.additional_node_tags
      )
    }
  })

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_base_provisioner" {
  # NodePool resource (formerly Provisioner) - Karpenter v1+
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name   = local.nodepool_name.default
      labels = module.kube_labels.tags
    }
    spec = {
      template = {
        metadata = {
          labels = merge(
            module.kube_labels.tags,
            { nodepool = local.nodepool_name.default },
            { "aml-modernized" = "aws-aml-orangelogic-cortex" }
          )
        }
      }
      nodeClassRef = {
        name  = local.nodeclass_name.default
        kind  = "EC2NodeClass"
        group = "karpenter.k8s.aws"
      }
      requirements = [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["spot"]
        },
        {
          key      = "karpenter.k8s.aws/instance-size"
          operator = "NotIn"
          values   = ["nano", "micro", "12xlarge", "16xlarge", "24xlarge", "metal"]
        },
        {
          key      = "karpenter.k8s.aws/instance-hypervisor"
          operator = "In"
          values   = ["nitro"]
        },
        {
          key      = "kubernetes.io/os"
          operator = "In"
          values   = ["linux"]
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["amd64"]
        },
        {
          key      = "karpenter.k8s.aws/instance-category"
          operator = "In"
          values   = ["c", "m", "r"]
        }
      ]
      limits = {
        cpu    = "1k"
        memory = "1000Gi"
      }
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "24h"
      }
    }
  })

  depends_on = [
    helm_release.karpenter,
    kubectl_manifest.karpenter_base_template
  ]
}
