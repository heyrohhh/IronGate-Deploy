output "lb_id" {
    value = aws_lb.load_balancer.id
}

output "lb_target_group_id" {
    value = aws_lb_target_group.lb_target.id
}

output "inventory_listen_id" {
    value = aws_lb_listener.inventory_listen.id
}

output "target_group_arn" {
    value = aws_lb_target_group.lb_target.arn
}