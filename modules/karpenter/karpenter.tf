resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "kube-system"
  chart            = "oci://mcr.microsoft.com/aks/karpenter/karpenter"
  version          = var.karpenter_version
  create_namespace = false # kube-system already exists
  wait             = true
  timeout          = 600

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
    name  = "settings.azure.vnetSubnetID"
    value = var.subnet_id
  }
  
  set {
    name  = "settings.azure.federatedIdentityCredentialID"
    value = azurerm_federated_identity_credential.karpenter_federated_identity.id
  }
  
  set {
    name  = "settings.clusterEndpoint"
    value = var.aks_api_server
  }
  
  set {
    name  = "settings.kubeletBootstrapToken"
    value = var.kubelet_bootstrap_token
  }

  # Controller configuration
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

  # Workload Identity configuration
  set {
    name  = "controller.serviceAccount.annotations.azure\\.workload\\.identity/client-id"
    value = azurerm_user_assigned_identity.karpenter.client_id
  }
  
  set {
    name  = "controller.podLabels.azure\\.workload\\.identity/use"
    value = "true"
  }

  # Environment variables
  set {
    name  = "controller.env[0].name"
    value = "VNET_SUBNET_ID"
  }
  set {
    name  = "controller.env[0].value"
    value = var.subnet_id
  }

  set {
    name  = "controller.env[1].name"
    value = "KUBELET_BOOTSTRAP_TOKEN"
  }
  set {
    name  = "controller.env[1].value"
    value = var.kubelet_bootstrap_token
  }

  set {
    name  = "controller.env[2].name"
    value = "SSH_PUBLIC_KEY"
  }
  set {
    name  = "controller.env[2].value"
    value = var.ssh_public_key
  }

  set {
    name  = "controller.env[3].name"
    value = "ARM_SUBSCRIPTION_ID"
  }
  set {
    name  = "controller.env[3].value"
    value = var.subscription_id
  }

  set {
    name  = "controller.env[4].name"
    value = "AZURE_NODE_RESOURCE_GROUP"
  }
  set {
    name  = "controller.env[4].value"
    value = var.node_resource_group
  }

  set {
    name  = "controller.env[5].name"
    value = "VNET_GUID"
  }
  set {
    name  = "controller.env[5].value"
    value = data.azurerm_virtual_network.aks_vnet.guid
  }

  depends_on = [time_sleep.wait_for_rbac]
}