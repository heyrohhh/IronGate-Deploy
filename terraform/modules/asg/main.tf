
resource "aws_iam_role" "ssm_role"{
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_launch_template" "inventory" {
  name_prefix   = "inventory"
  image_id      = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  vpc_security_group_ids = [var.ec2_sg_id]
   iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }
user_data = base64encode(<<-USERDATA
#!/bin/bash
set -e

dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

mkdir -p /usr/libexec/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/libexec/docker/cli-plugins/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose

mkdir -p /home/ec2-user/app

cat <<'COMPOSE' > /home/ec2-user/app/docker-compose.yml
services:
  database:
    image: mysql:8.0
    env_file:
      - .env
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped
    networks:
      - app-network

  backend:
    image: heyrohhh/iniback:v1
    env_file:
      - .env
    depends_on:
      - database
    restart: unless-stopped
    networks:
      - app-network
  frontend:
   image: heyrohhh/inifront:v3
   networks:
    - app-network

  nginx:
   image: nginx:latest
   ports:
    - "80:80"
   volumes:
    - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
   depends_on:
    - frontend
    - backend 

volumes:
  mysql_data:

networks:
  app-network:
    driver: bridge
COMPOSE

cat <<'NGINX' > /home/ec2-user/app/nginx.conf
resolver 127.0.0.11 valid=10s ipv6=off;

server {
  listen 80;

  location / {
    set $frontend frontend;
    proxy_pass http://$frontend:80;
  }

  location /api/ {
    set $backend backend;
    proxy_pass http://$backend:3001;
  }

  location /health {
    return 200 "OK";
  }
}


NGINX

cat <<'ENV' > /home/ec2-user/app/.env
MYSQL_ROOT_PASSWORD=secret123
MYSQL_DATABASE=inventory
ENV

chown -R ec2-user:ec2-user /home/ec2-user/app

su - ec2-user -c "
cd /home/ec2-user/app &&
docker compose pull &&
docker compose up -d
"
USERDATA
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
  key                 = "Role"
  value               = "app"
  propagate_at_launch = true
}

tag {
  key                 = "Name"
  value               = "inventory-app"
  propagate_at_launch = true
}

}
