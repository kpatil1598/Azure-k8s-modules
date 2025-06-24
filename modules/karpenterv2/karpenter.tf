resource "azurerm_user_assigned_identity" "karpenter" {
  name                = "karpenter-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_federated_identity_credential" "karpenter" {
  name                = "karpenter-federated"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.karpenter.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}

resource "azurerm_role_assignment" "karpenter_contributor" {
  scope                = var.node_resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = var.namespace
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "0.36.0" # use latest stable
  create_namespace = true

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = "not-used-on-azure"
  }

  set {
    name  = "controller.serviceAccount.annotations.\"azure.workload.identity/client-id\""
    value = azurerm_user_assigned_identity.karpenter.client_id
  }

  set {
    name  = "settings.azure.subscriptionId"
    value = var.subscription_id
  }

  set {
    name  = "settings.azure.tenantId"
    value = var.tenant_id
  }

  set {
    name  = "settings.azure.resourceGroup"
    value = var.node_resource_group_name
  }

  set {
    name  = "settings.azure.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.azure.vmFamily"
    value = "Standard" # change to match your node families
  }

  depends_on = [
    azurerm_role_assignment.karpenter_contributor,
    azurerm_federated_identity_credential.karpenter
  ]
}
