output "subnet_a_id" {
  value = aws_subnet.subnet_a.id
}

output "subnet_b_id" {
  value = aws_subnet.subnet_b.id
}

output "nginx_ingress_helm_status" {
  value = helm_release.nginx_ingress.status
}
# output "subnet_c_id" {
#   value = aws_subnet.subnet_c.id
# }