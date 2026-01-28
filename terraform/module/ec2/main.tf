provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "main_instance" {
    count = 3
    ami = var.ami
    instance_type = "t3.micro"
    subnet_id = var.ec2_subnet
    vpc_security_group_ids = [var.sg_id]
    key_name = var.key_name
    root_block_device {
        volume_size = 20
        volume_type = "gp3"
    }
}

resource "aws_lb_target_group_attachment" "inventory_attach" {
  count            = length(aws_instance.main_instance)
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.main_instance[count.index].id
  port             = 80
}

resource "aws_instance" "bastion_host" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id 
  vpc_security_group_ids      = [var.bastion_sg_id] 
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = { Name = "Bastion-Host" }
}


output "bastion_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "private_ips" {
  value = aws_instance.main_instance[*].private_ip
}