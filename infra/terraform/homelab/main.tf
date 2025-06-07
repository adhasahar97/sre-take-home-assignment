terraform {
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "microk8s"
  }
}

module "cloudflare" {
  source                 = "../modules/cloudflare"
  cloudflare_tunnel_name = var.cloudflare_tunnel_name
  cloudflare_account_id  = var.cloudflare_account_id
}

module "helm" {
  source = "../modules/helm"
}
