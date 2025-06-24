provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    # or use config_raw if you want to dynamically generate from AKS
  }
}