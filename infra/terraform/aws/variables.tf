variable "cloudflare_tunnel_name" {
    description = "The name of the Cloudflare tunnel"
    type        = string
}

variable "cloudflare_api_token" {
    description = "The API token used to authenticate with Cloudflare's API"
    type        = string
    default     = ""
    sensitive = true
}

variable "cloudflare_account_id" {
    description = "The name of the Cloudflare tunnel"
    type        = string
    default     = ""
}

variable "cloudflare_domain" {
    description = "The hostname to be used with the Cloudflare tunnel"
    type        = string
    default     = ""
}

variable "argocd_admin_password" {
    description = "The password for the ArgoCD admin user"
    type        = string
    default     = ""
    sensitive = true
}