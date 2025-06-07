output "cloudflare_tunnel_token" {
  value = cloudflare_zero_trust_tunnel_cloudflared.k8s-tunnel.tunnel_token
}
output "cloudflare_tunnel_account_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.k8s-tunnel.account_id
}
output "cloudflare_tunnel_name" {
  value = var.cloudflare_tunnel_name
}