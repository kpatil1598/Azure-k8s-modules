
# resource "azurerm_public_ip" "lb_ip" {
#   name                = "internal_ipv4"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Standard"

#   tags = var.tags
# }

# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   namespace  = "kube-system"
#   create_namespace = true

#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   version    = "4.10.1"

#   values = [
#     <<-EOF
# controller:
#   ingressClassResource:
#     name: nginx
#     enabled: true
#   service:
#     annotations:
#       service.beta.kubernetes.io/azure-load-balancer-internal: "true"
#     loadBalancerIP: "52.255.237.246" # Uncomment if you want to specify a static IP
#     ipFamilies: ["IPv4", "IPv6"]
#     ipFamilyPolicy: "PreferDualStack"
#     internal:
#       enabled: true
# EOF
#   ]
# }

# resource "azurerm_public_ip" "nginx_ingress" {
#   name                = "nginx-public-ip"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   tags                = var.tags
# }

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  namespace        = "kube-system"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.3"
  wait = true
  timeout = "600"

  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }

  set {
    name  = "controller.ingressClassResource.enabled"
    value = "true"
  }

  set {
    name  = "controller.ingressClassResource.default"
    value = "false"
  }

  # set {
  #   name  = "controller.service.loadBalancerIP"
  #   value = azurerm_public_ip.nginx_ingress.ip_address
  # }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = var.resource_group_name
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "false"
  }

  set {
    name  = "controller.service.ipFamilies[0]"
    value = "IPv4"
  }
  set {
    name  = "controller.service.ipFamilies[1]"
    value = "IPv6"
  }

  set {
    name  = "controller.service.ipFamilyPolicy"
    value = "PreferDualStack"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "defaultBackend.enabled"
    value = "true"
  }

 # depends_on = [azurerm_public_ip.nginx_ingress]
}
