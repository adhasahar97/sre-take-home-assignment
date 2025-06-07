locals {
  list_of_releases = {
    "argocd" = {
      name       = "argocd"
      repository = "https://argoproj.github.io/argo-helm"
      chart      = "argo-cd"
      namespace  = "argocd"
      version    = "8.0.12"
      values     = {

      }
    },
    "cloudflare-tunnel" = {
      name       = "cloudflare-tunnel"
      repository = "https://helm.strrl.dev"
      chart      = "cloudflare-tunnel-ingress-controller"
      namespace  = "cloudflare-tunnel"
      version    = "0.0.16"
      values     = {
        "cloudflare_tunnel_token"      = var.cloudflare_api_token
        "cloudflare_tunnel_account_id" = var.cloudflare_tunnel_account_id
        "cloudflare_tunnel_name"       = var.cloudflare_tunnel_name
        "cloudflare_domain"            = var.cloudflare_domain
      }
    }
  }
}

# Trigger update test

resource "helm_release" "release" {
  for_each = local.list_of_releases

  name             = each.value.name
  repository       = each.value.repository
  chart            = each.value.chart
  version          = each.value.version
  namespace        = each.value.namespace
  create_namespace = lookup(each.value, "create_namespace", true)

  values = try(
    [templatefile("${path.module}/values/values-${each.value.name}.yaml", each.value.values)],
    []
  )
}