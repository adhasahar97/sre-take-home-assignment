terraform {
  backend "s3" {
    bucket = "adha-homelab-iac-terraform-state"
    key    = "terraform/feedme-sre-aws"
    region = "ap-southeast-1"
  }
}