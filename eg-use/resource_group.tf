module "resource_group" {
  source   = "C:\\Users\\chava\\Desktop\\k8s-module\\modules\\\\rg"
  resource_group_name = "rg-aks-dev"
  location = "West Europe"
  tags = {
    environment = "dev"
    owner       = "team-aks"
  }
}
