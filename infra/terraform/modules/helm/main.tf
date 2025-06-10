locals {
  list_of_releases = {
    "argocd" = {
      name       = "argocd"
      repository = "https://argoproj.github.io/argo-helm"
      chart      = "argo-cd"
      namespace  = "argocd"
      version    = "8.0.12"
      values     = {
        "hostname" = var.cloudflare_domain
      }
    },
    "cloudflare-tunnel" = {
      name       = "cloudflare-tunnel"
      repository = "https://helm.strrl.dev"
      chart      = "cloudflare-tunnel-ingress-controller"
      namespace  = "cloudflare-tunnel"
      version    = "0.0.18"
      values     = {
        "cloudflare_tunnel_token"      = var.cloudflare_api_token
        "cloudflare_tunnel_account_id" = var.cloudflare_tunnel_account_id
        "cloudflare_tunnel_name"       = var.cloudflare_tunnel_name
        "cloudflare_domain"            = var.cloudflare_domain
        "argocd_admin_password"        = var.argocd_admin_password
      }
    },
    "ingress-nginx" = {
      name       = "ingress-nginx"
      repository = "https://kubernetes.github.io/ingress-nginx"
      chart      = "ingress-nginx"
      namespace  = "ingress-nginx"
      version    = "4.12.3"
      values     = {
        
      }
    },
    # "grafana" = {
    #   name       = "grafana"
    #   repository = "https://grafana.github.io/helm-charts"
    #   chart      = "grafana"
    #   namespace  = "observability"
    #   version    = "9.2.2"
    #   values     = {
        
    #   }
    # },
    "kube-prometheus-stack" = {
      name       = "kube-prometheus-stack"
      repository = "https://prometheus-community.github.io/helm-charts"
      chart      = "kube-prometheus-stack"
      namespace  = "observability"
      version    = "73.2.0"
      values     = {
        
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
  set {
    name  = "templates_hash"
    value = try(
      sha1(filesha1("${path.module}/values/values-${each.value.name}.yaml")),
      ""
    )
  }

  values = try(
    [templatefile("${path.module}/values/values-${each.value.name}.yaml", each.value.values)],
    []
  )
}