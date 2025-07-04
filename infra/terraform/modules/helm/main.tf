resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.12.3"
  values     = [
    templatefile("${path.module}/values/values-ingress-nginx.yaml", {
    })
  ]
  create_namespace = true
}

resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "observability"
  version    = "73.2.0"
  values     = [
    templatefile("${path.module}/values/values-kube-prometheus-stack.yaml", {
      hostname = var.cloudflare_domain
    })
  ]
  create_namespace = true
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = "observability"
  version    = "6.30.1"
  values     = [
    templatefile("${path.module}/values/values-loki.yaml", {
    })
  ]
  create_namespace = true
}

resource "helm_release" "alloy" {
  name       = "alloy"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  namespace  = "observability"
  version    = "1.1.1"
  values     = [
    templatefile("${path.module}/values/values-alloy.yaml", {
    })
  ]
  create_namespace = true
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "8.0.17"
  values     = [
    templatefile("${path.module}/values/values-argocd.yaml", {
      hostname              = var.cloudflare_domain
      argocd_admin_password = var.argocd_admin_password
    })
  ]
  create_namespace = true
}