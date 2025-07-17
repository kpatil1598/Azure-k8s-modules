terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" version = "~>3.0" }
    kubernetes = { source = "hashicorp/kubernetes" }
    helm = { source = "hashicorp/helm" }
  }
}

provider "azurerm" {
  features = {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "karpenter" {
  name                = "${var.cluster_name}-karpentermsi"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name
  default_node_pool {
    name            = "agentpool"
    node_count      = var.node_count
    vm_size         = var.agent_vm_size
    os_type         = "Linux"
    type            = "VirtualMachineScaleSets"
    enable_auto_scaling = false
  }
  identity {
    type = "SystemAssigned"
  }
  enable_oidc_issuer     = true
  enable_workload_identity = true
  network_profile {
    network_plugin        = "azure"
    network_policy        = "Cilium"
    network_plugin_mode   = "Overlay"
    network_profile_id    = null
  }
  tags = var.tags
}

resource "azurerm_role_assignment" "vm_contrib" {
  for_each = toset(["Virtual Machine Contributor", "Network Contributor", "Managed Identity Operator"])
  scope              = data.azurerm_resource_group.node_rg.id
  role_definition_name = each.key
  principal_id       = azurerm_user_assigned_identity.karpenter.principal_id
}

data "azurerm_resource_group" "node_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}

resource "azurerm_kubernetes_cluster_user_assigned_identity_binding" "binding" {
  kubernetes_cluster_id      = azurerm_kubernetes_cluster.aks.id
  user_assigned_identity_id  = azurerm_user_assigned_identity.karpenter.id
}

resource "azurerm_kubernetes_cluster_node_pool" "karpenter_pool" {
  name                  = "karpenter"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.karpenter_vm_size
  node_count            = 0
  max_count             = var.karpenter_max
  min_count             = var.karpenter_min
  enable_auto_scaling   = true
}

resource "null_resource" "federated_cred" {
  provisioner "local-exec" {
    command = <<EOT
      az identity federated-credential create \
        --name KARPENTER_FID \
        --identity-name ${azurerm_user_assigned_identity.karpenter.name} \
        --resource-group ${azurerm_resource_group.rg.name} \
        --issuer "$(az aks show --name ${azurerm_kubernetes_cluster.aks.name} \
            --resource-group ${azurerm_resource_group.rg.name} \
            --query "oidcIssuerProfile.issuerUrl" -otsv)" \
        --subject "system:serviceaccount:${var.karpenter_namespace}:${var.karpenter_sa}" \
        --audience api://AzureADTokenExchange
    EOT
  }
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://mcr.microsoft.com/aks/karpenter/karpenter"
  version    = var.karpenter_version
  namespace  = var.karpenter_namespace
  create_namespace = true
  values = [
    <<EOF
controller:
  resources:
    requests:
      cpu: "1"
      memory: "1Gi"
    limits:
      cpu: "1"
      memory: "1Gi"
settings:
  clusterName: ${var.cluster_name}
  clusterEndpoint: ${azurerm_kubernetes_cluster.aks.kube_config[0].host}
  subscriptionId: ${data.azurerm_subscription.primary.subscription_id}
  tenantId: ${data.azurerm_subscription.primary.tenant_id}
# (additional requirements such as sku-family, arch filters, etc.)
EOF
  ]
}

data "azurerm_subscription" "primary" {}






