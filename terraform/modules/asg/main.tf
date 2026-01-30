resource "aws_launch_template" "inventory" {
  name_prefix   = "inventory"
  image_id      = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  vpc_security_group_ids = [var.ec2_sg_id]
  key_name = "Portfolio_key"
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
    version = "$Latest"
  }

 

   tag {
    key                 = "Name"
    value               = "inventory-app"
    propagate_at_launch = true
  }
}
