data "aws_lbs" "nginx_ingress" {
  tags = {
    "eks:eks-cluster-name" = "feedme-sre"
  }

    depends_on = [
        var.nginx_ingress_helm_status
    ]
}