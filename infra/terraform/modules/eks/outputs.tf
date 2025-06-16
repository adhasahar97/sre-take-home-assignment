output "cluster" {
    value = aws_eks_cluster.feedme-sre
}

output "aws_lbs" {
    value = data.aws_lbs.nginx_ingress
}