terraform {
  backend "s3" {
    bucket = "adha-homelab-iac-terraform-state"
    key    = "terraform/feedme-sre-aws-ap-southeast-5"
    region = "ap-southeast-1"
  }
}