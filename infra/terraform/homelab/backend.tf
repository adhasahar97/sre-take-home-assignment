terraform {
  backend "s3" {
    bucket = "adha-homelab-iac-terraform-state"
    key    = "terraform/feedme-sre"
    region = "ap-southeast-1"
  }
}