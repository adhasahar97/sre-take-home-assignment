terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "random_password" "tunnel_secret" {
  length = 64
}

# resource "cloudflare_zero_trust_tunnel_cloudflared" "k8s-tunnel" {
#   account_id = var.cloudflare_account_id
#   name       = var.cloudflare_tunnel_name
#   secret     = base64sha256(random_password.tunnel_secret.result)
# }