output "vpc_id" {
  value = aws_vpc.vpc_main.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "public_subnet2_id" {
  value = aws_subnet.public_subnet2.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}

output "bastion_sg_id" {
    value = aws_security_group.bastion_sg.id
}