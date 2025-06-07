terraform {
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "feedme-sre"
  }
}

module "helm" {
  source = "../modules/helm"
  cloudflare_api_token         = var.cloudflare_api_token
  cloudflare_tunnel_account_id = var.cloudflare_account_id
  cloudflare_tunnel_name       = var.cloudflare_tunnel_name
  cloudflare_domain            = var.cloudflare_domain
  argocd_admin_password        = var.argocd_admin_password
}
