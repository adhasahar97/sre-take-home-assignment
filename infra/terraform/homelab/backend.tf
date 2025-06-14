terraform {
  backend "s3" {
    bucket = "adha-homelab-iac-terraform-state"
    key    = "terraform/feedme-sre-homelab-cluster-1"
    region = "ap-southeast-1"
  }
}