resource "helm_release" "cloudflare-tunnel" {
  name       = "cloudflare-tunnel"
  repository = "https://helm.strrl.dev"
  chart      = "cloudflare-tunnel-ingress-controller"
  namespace  = "cloudflare-tunnel"
  version    = "0.0.18"
  values     = [
    templatefile("${path.module}/values/values-cloudflare-tunnel.yaml", {
    "cloudflare_tunnel_token"      = var.cloudflare_api_token
    "cloudflare_tunnel_account_id" = var.cloudflare_tunnel_account_id
    "cloudflare_tunnel_name"       = var.cloudflare_tunnel_name
    "cloudflare_domain"            = var.cloudflare_domain
    "argocd_admin_password"        = var.argocd_admin_password
    })
  ]
  create_namespace = true
}

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
  depends_on = [ helm_release.cloudflare-tunnel ]
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
  depends_on = [ kubernetes_ingress_v1.cf-to-nginx ]
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
resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-distributed"
  namespace  = "observability"
  version    = "1.42.0"
  values     = [
    templatefile("${path.module}/values/values-tempo.yaml", {
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
  depends_on = [ kubernetes_ingress_v1.cf-to-nginx ]
}

resource "kubernetes_ingress_v1" "cf-to-nginx" {
  metadata {
    name = "cf-to-nginx"
    namespace = helm_release.ingress-nginx.namespace
    annotations = {
      "cloudflare-tunnel-ingress-controller.strrl.dev/backend-protocol" = "http"
      "cloudflare-tunnel-ingress-controller.strrl.dev/proxy-ssl-verify" = "off"
    }
  }
  spec {
    ingress_class_name = "cloudflare-tunnel"
    rule {
      host = "*.adhshr.xyz"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "ingress-nginx-controller"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [ helm_release.cloudflare-tunnel, helm_release.ingress-nginx]
}
resource "kubernetes_storage_class_v1" "gp2-default" {
  metadata {
    name = "gp2-default"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    } 
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Delete"
  parameters = {
    type = "gp2"
    fsType = "ext4"
  }
  volume_binding_mode = "WaitForFirstConsumer"
}
