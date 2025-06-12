
# resource "azurerm_public_ip" "lb_ip" {
#   name                = "internal_ipv4"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Standard"

#   tags = var.tags
# }

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "kube-system"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"

  values = [
    <<-EOF
controller:
  ingressClassResource:
    name: nginx
    enabled: true
  service:
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    #loadBalancerIP: "var.internal_lb_ip" # Uncomment if you want to specify a static IP
    ipFamilies: ["IPv4", "IPv6"]
    ipFamilyPolicy: "PreferDualStack"
    internal:
      enabled: true
EOF
  ]
}
