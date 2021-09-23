output "alb_address" {
    value = aws_lb.pet-lb.dns_name
}