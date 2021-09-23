output "alb_address" {
    value = aws_lb.pet-lb.dns_name
}
/*
output "db_addr" {
    value = aws_db_instance.default.endpoint
}*/