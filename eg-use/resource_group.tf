module "resource_group" {
  source   = "..\\modules\\rg"
  resource_group_name = "rg-aks-dev"
  location = "West Europe"
  tags = {
    environment = "dev"
    owner       = "team-aks"
  }
}
