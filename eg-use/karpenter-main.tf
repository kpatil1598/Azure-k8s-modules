data "azurerm_client_config" "current" {}

module "karpenter" {
  source = "../modules/karpenter" # adjust path as needed

  name                = "karpenter"
  location            = "eastus"
  resource_group_name = "rg-aks-dev"
  node_resource_group = module.aks.node_resource_group
  cluster_name        = "aks-cluster"
  aks_api_server      = module.aks.kube_config_host

  #clusrer_endpoint       = module.aks.kube_config_host

  aks_host               = module.aks.kube_config_host
  client_certificate     = module.aks.kube_config_client_certificate
  client_key             = module.aks.kube_config_client_key
  cluster_ca_certificate = module.aks.kube_config_cluster_ca_certificate

  subscription_id = data.azurerm_client_config.current.subscription_id
  subnet_id       = module.networking.private_subnet_ids["private-subnet-1"]

  karpenter_version           = "0.7.0"
  #karpenter_provider_version  = "0.0.17"
  issuer_url = module.aks.issuer_url # Replace with your actual issuer URL
  
  # Add VNET and subnet names  
  vnet_name   = "aks-vnet"
  subnet_name = "private-subnet-1"
  
  # Add SSH public key - you can generate one or use an existing one
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7vbqabOJjQxVqgJ8VQKCCxO26wBL5C66okqO1UBfRKh7JmXrxWz3Q3RGsXlnf6iu6koC2fGAiJDhD1LolLsEFfGwk4jpqDHDfMuHmmzy1p3BzHriFK4m8khLnT07aHcTmvLQ1fDPKqY1B7h6Pyc9jemyMx6gLpAGVR1POA8tBmI7/0A2jS485d14T1PEY8IBH8E6GkZbXlZML5v7bOwht/eMOG6xqEIOOMrF6bYtnJAZAn0x7/2dG0hmJdv+cuOWHk/uM38ofJ3FWJVM9X4hLAFhtGTK+2XfylMsSu3z+7kY8oduSXTOiZet9rk2Hf/l/gitx4VSsxAiAIuQ/r9IMe5oQ3dLDOakcaERofZkqgXzFQwIDAQAB karpenter@azure"
  
  depends_on = [module.resource_group, module.aks, module.networking]
}                                    # set matching version