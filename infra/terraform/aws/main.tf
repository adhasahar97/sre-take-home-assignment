terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

ephemeral "aws_eks_cluster_auth" "feedme-sre" {
  name = module.eks.cluster.id
}

provider "kubernetes" {
  host                   = module.eks.cluster.endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster.certificate_authority[0].data)
  token                  = ephemeral.aws_eks_cluster_auth.feedme-sre.token
}

resource "kubernetes_namespace" "debug" {
  metadata {
    name = "debut-namespace"
  }
}

# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster.endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster.certificate_authority[0].data)
#     token                  = ephemeral.aws_eks_cluster_auth.feedme-sre.token
#   }
# }

provider "aws" {
  region = "ap-southeast-5"
}

module "vpc" {
  source = "../modules/vpc"
  vpc_cidr_block = "10.0.0.0/16"
}

module "eks" {
  source = "../modules/eks"
  subnet_a_id = module.vpc.subnet_a_id
  subnet_b_id = module.vpc.subnet_b_id
}

# module "helm" {
#   source = "../modules/helm"
#   cloudflare_api_token         = var.cloudflare_api_token
#   cloudflare_tunnel_account_id = var.cloudflare_account_id
#   cloudflare_tunnel_name       = var.cloudflare_tunnel_name
#   cloudflare_domain            = var.cloudflare_domain
#   argocd_admin_password        = var.argocd_admin_password
# }
