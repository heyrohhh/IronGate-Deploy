resource "aws_instance" "bastion_host" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  subnet_id = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.bastion_sg_id] 
  key_name                    = "Portfolio_key"
  associate_public_ip_address = true

  tags = { 
    Name = "Bastion-Host" 
         }
}

output "bastion_ip" {
  value = aws_instance.bastion_host.public_ip
}