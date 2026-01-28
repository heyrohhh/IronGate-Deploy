#creating vpc

resource "aws_vpc" "vpc_main" {
       cidr_block = var.vpc_cidr
       enable_dns_hostnames = var.dns_hostname
       enable_dns_support = var.dns_support
}

#internet_gateway

resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.vpc_main.id
}

resource "aws_subnet" "public_subnet"{
    vpc_id = aws_vpc.vpc_main.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = var.zone[0]
}

resource "aws_subnet" "public_subnet2"{
    vpc_id = aws_vpc.vpc_main.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone = var.zone[1]
}

resource "aws_subnet" "private_subnet"{
    vpc_id = aws_vpc.vpc_main.id
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = false
    availability_zone = var.zone[0]
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.vpc_main.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.vpc_main.id
}

resource "aws_route_table_association" "public_assoc" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc2" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "private_assoc" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}

#security group

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.vpc_main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# nat gate way
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "main_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id # Public subnet ka ID
  tags = { Name = "Main-NAT" }
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_route" "private_internet_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main_nat.id
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.vpc_main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Yahan aapka laptop connect hoga
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-private-sg"
  vpc_id = aws_vpc.vpc_main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
 ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # BASTION se SSH (Ansible ke liye)
  }
   ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}