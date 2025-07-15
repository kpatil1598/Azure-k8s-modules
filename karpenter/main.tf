resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "kube-system"
  repository       = "oci://mcr.microsoft.com/aks/karpenter/karpenter"
  chart            = "karpenter"
  version          = var.chart_version
  create_namespace = false
  wait             = true

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      CLUSTER_NAME                  = var.cluster_name
      CLUSTER_ENDPOINT              = var.cluster_endpoint
      BOOTSTRAP_TOKEN               = var.kubelet_bootstrap_token
      SSH_PUBLIC_KEY                = var.ssh_public_key
      NETWORK_PLUGIN                = var.network_plugin
      NETWORK_PLUGIN_MODE           = var.network_plugin_mode
      NETWORK_POLICY                = var.network_policy
      VNET_SUBNET_ID                = var.vnet_subnet_id
      VNET_GUID                     = var.vnet_guid
      NODE_IDENTITIES               = var.node_identities
      AZURE_SUBSCRIPTION_ID         = var.subscription_id
      AZURE_LOCATION                = var.location
      AZURE_RESOURCE_GROUP_MC       = var.mc_resource_group
      KARPENTER_SERVICE_ACCOUNT_NAME = var.service_account_name
      KARPENTER_USER_ASSIGNED_CLIENT_ID = var.client_id
      LOG_LEVEL                     = var.log_level
    })
  ]
}
