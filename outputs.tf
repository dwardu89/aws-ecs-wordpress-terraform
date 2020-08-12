output "loadbalancer_url" {
  value = aws_lb.lb.dns_name
}