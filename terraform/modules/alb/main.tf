

# target group

resource "aws_lb_target_group" "lb_target" {
  name     = "lb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
     path = "/health"
     interval = 30
     timeout = 5
     healthy_threshold = 3
     unhealthy_threshold = 2
     matcher = "200"
  }
}

#load balancer

resource "aws_lb" "load_balancer" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  
  tags = {
     Name = "load_balancer"
  }
}

resource "aws_lb_listener" "inventory_listen" {
  load_balancer_arn =  aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target.arn
  }
}