terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# provider "helm" {
#   kubernetes = {
#     host                   = var.cluster_endpoint
#     cluster_ca_certificate = base64decode(var.cluster_ca_cert)
#     exec = {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
#       command     = "aws"
#     }
#   }
# }

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "../modules/vpc"
  vpc_cidr_block = "10.0.0.0/16"
}