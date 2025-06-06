terraform {
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "helm" {
  source                       = "../modules/helm"
}
