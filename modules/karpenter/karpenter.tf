resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "kube-system"
  chart      = "oci://mcr.microsoft.com/aks/karpenter/karpenter"
  version    = var.karpenter_version
  create_namespace = true
  
  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "settings.azure.subscriptionId"
    value = var.subscription_id
  }
  set {
    name  = "settings.azure.tenantId"
    value = data.azurerm_client_config.current.tenant_id
  }
  set {
    name  = "settings.azure.resourceGroup"
    value = var.resource_group_name
  }
  set {
    name  = "settings.azure.nodeResourceGroup"
    value = var.node_resource_group
  }
  set {
    name  = "settings.azure.userAssignedIdentityID"
    value = azurerm_user_assigned_identity.karpenter.id
  }
  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }
  set {
    name  = "controller.resources.requests.memory"
    value = "256Mi"
  }
  set {
    name  = "controller.resources.limits.cpu"
    value = "200m"
  }
  set {
    name  = "controller.resources.limits.memory"
    value = "512Mi"
  }
  set {
    name  = "controller.serviceAccount.annotations.\"azure.workload.identity/client-id\""
    value = "19249f55-3830-488e-a37e-513754a5fe50"
  }
  set {
    name  = "settings.clusterEndpoint"
    value = var.aks_api_server
  }
  # Fixed: Corrected parameter name and format
  set {
    name  = "settings.azure.vnetSubnetID"
    value = "/subscriptions/f7c3be65-2edf-420b-9d7b-25bca67f650c/resourceGroups/rg-aks-dev/providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/private-subnet-1"
  }
  set {
    name  = "settings.azure.federatedIdentityCredentialID"
    value = azurerm_federated_identity_credential.karpenter_federated_identity.id
  }
  # Fixed: Single kubelet bootstrap token setting
  set {
    name  = "settings.kubeletBootstrapToken"
    value = var.kubelet_bootstrap_token
  }
  
  depends_on = [
    azurerm_user_assigned_identity.karpenter,
    azurerm_federated_identity_credential.karpenter_federated_identity
  ]
}
