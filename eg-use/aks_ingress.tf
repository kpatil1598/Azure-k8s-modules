# module "aks_ingress" {
#   source = "C:\\Users\\chava\\Desktop\\k8s-module\\root-modules\\aks_ingress"

#   location            = "centralindia"
# resource_group      = module.resource_group.resource_group_name
# aks_name            = "aks-cluster"
# aks_resource_group  = module.resource_group.resource_group_name

# appgw_name          = "agic-appgw"
# appgw_subnet_id     = values(module.networking.public_subnet_ids)[0] # Adjust based on your vnet module output
# appgw_is_public     = true
# appgw_min_capacity  = 2
# appgw_max_capacity  = 5

# agic_identity_name  = "agic-identity"
# agic_chart_version  = "1.7.1"
# agic_namespace      = "ingress-azure"
# agic_watch_namespace = ""

# kubeconfig_path     = "~/.kube/config"
# kubeconfig_context  = ""
# tags = {
#   environment = "dev"
#   project     = "aks-ingress"
# }
#     # depends_on = [
#     #     module.resource_group,
#     #     module.networking
#     # ]
# }