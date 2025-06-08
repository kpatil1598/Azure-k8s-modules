module "resource_group" {
  source   = "C:\\Users\\chava\\Desktop\\k8s-module\\modules\\\\rg"
  name     = "my-rg"
  location = "West Europe"
  tags = {
    environment = "dev"
    owner       = "team-aks"
  }
}
