
#alb security group

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "alb_sg"
  }

  ingress {
       from_port = 80
       to_port = 80
       protocol = "TCP" 
       cidr_blocks = ["0.0.0.0/0"] 
  }
 egress {
       from_port = 0
       to_port = 0
       protocol = "-1"
       cidr_blocks=["0.0.0.0/0"]
 }
}

# ec2 Security_group

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ec2_sg"
  }

ingress {
  description     = "HTTP from ALB"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [aws_security_group.alb_sg.id]
}


 egress {
       from_port = 0
       to_port = 0
       protocol = "-1"
       cidr_blocks=["0.0.0.0/0"]
 }
}