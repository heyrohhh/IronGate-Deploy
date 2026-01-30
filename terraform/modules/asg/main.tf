resource "aws_launch_template" "inventory" {
  name_prefix   = "inventory"
  image_id      = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  vpc_security_group_ids = [var.ec2_sg_id]
  key_name = "Portfolio_key"
 user_data = base64encode(<<-EOF
 #!/bin/bash
 dnf update -y
 dnf install -y docker
 systemctl start docker
 systemctl enable docker
 usermod -aG docker ec2-user
 mkdir -p /usr/local/lib/docker/cli-plugins
 curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
 chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
 systemctl restart docker
 EOF
)
  tag_specifications {
     resource_type = "instance"

     tags = {
     Name = "inventory-app"
     Role = "app"
            }
        }
    }

resource "aws_autoscaling_group" "asg" {
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  vpc_zone_identifier  = var.private_subnet_ids
  target_group_arns  = [var.target_group_arn]
  health_check_type  = "ELB"
  health_check_grace_period = 300

  launch_template {
  id      = aws_launch_template.inventory.id
  version = aws_launch_template.inventory.latest_version
}

 

   tag {
    key                 = "Name"
    value               = "app"
    propagate_at_launch = true
  }
}
