# # AKSNodeClass (Azure Linux)
# resource "kubectl_manifest" "aks_node_class" {
#   yaml_body = yamlencode({
#     apiVersion = "karpenter.azure.com/v1alpha2"
#     kind       = "AKSNodeClass"
#     metadata = {
#       name = "default-azurelinux"
#       annotations = {
#         "kubernetes.io/description" = "General purpose AKSNodeClass for running Azure Linux nodes"
#       }
#     }
#     spec = {
#       imageFamily = "AzureLinux"
#     }
#   })

#   depends_on = [helm_release.karpenter]
# }

# # NodePool (ARM64, Linux, On-demand)
# resource "kubectl_manifest" "node_pool" {
#   yaml_body = yamlencode({
#     apiVersion = "karpenter.sh/v1beta1"
#     kind       = "NodePool"
#     metadata = {
#       name = "arm-nodepool"
#     }
#     spec = {
#       weight = 10
#       disruption = {
#         consolidationPolicy = "WhenEmpty"      #"WhenEmptyOrUnderutilized"
#         consolidateAfter    = "1s"
#       }
#       template = {
#         spec = {
#           nodeClassRef = {
#             group = "karpenter.azure.com"
#             kind  = "AKSNodeClass"
#             name  = "default-azurelinux"
#           }
#           requirements = [
#             {
#               key      = "kubernetes.io/arch"
#               operator = "In"
#               values   = ["arm64"]
#             },
#             {
#               key      = "kubernetes.io/os"
#               operator = "In"
#               values   = ["linux"]
#             },
#             {
#               key      = "karpenter.sh/capacity-type"
#               operator = "In"
#               values   = ["on-demand"]
#             },
#             {
#               key      = "karpenter.azure.com/sku-family"
#               operator = "In"
#               values   = ["D"]
#             }
#           ]
#         }
#       }
#     }
#   })

#   depends_on = [
#     kubectl_manifest.aks_node_class,
#     helm_release.karpenter
#     ]
# }