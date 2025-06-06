terraform {
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "microk8s"
  }
}

module "helm" {
  source = "../modules/helm"
}
