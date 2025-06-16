variable "cloudflare_tunnel_name" {
    description = "The name of the Cloudflare tunnel"
    type        = string
}

variable "cloudflare_account_id" {
    description = "The name of the Cloudflare tunnel"
    type        = string
    default     = ""
}

variable "aws_lb" {
    description = "The AWS Load Balancer"
    type        = string
}
