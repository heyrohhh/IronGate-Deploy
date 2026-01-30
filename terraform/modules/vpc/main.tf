#Creating vpc

resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "Inventory_vpc"
    }
}

data "aws_availability_zones" "zone" {
  state = "available"
}

resource "aws_subnet" "public_primary_subnet" {
        vpc_id = aws_vpc.main_vpc.id 
        cidr_block = "10.0.1.0/24"
        availability_zone = data.aws_availability_zones.zone.names[0]
        map_public_ip_on_launch = true
        tags = {
            Name = "public_primary_subnet"
        }
}

resource "aws_subnet" "public_secondary_subnet" {
        vpc_id = aws_vpc.main_vpc.id 
        cidr_block = "10.0.2.0/24"
        availability_zone = data.aws_availability_zones.zone.names[1]
        map_public_ip_on_launch = true
        tags = {
            Name = "public_secondary_subnet"
        }
}

resource "aws_subnet" "private_primary_subnet" {
        vpc_id = aws_vpc.main_vpc.id 
        cidr_block = "10.0.3.0/24"
        availability_zone = data.aws_availability_zones.zone.names[0]
        map_public_ip_on_launch = false
        tags = {
            Name = "private_primary_subnet"
        }
}

resource "aws_subnet" "private_secondary_subnet" {
        vpc_id = aws_vpc.main_vpc.id 
        cidr_block = "10.0.4.0/24"
        availability_zone = data.aws_availability_zones.zone.names[1]
        map_public_ip_on_launch = false
        tags = {
            Name = "private_secondary_subnet"
        }
}


#igw and route

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "igw for public"
    }
}


resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc.id 

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "pub_rt_assoc1"{
       subnet_id = aws_subnet.public_primary_subnet.id
       route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub_rt_assoc2"{
       subnet_id = aws_subnet.public_secondary_subnet.id
       route_table_id = aws_route_table.public_rt.id
}

# nat gateway 

resource "aws_eip" "eip" {
  domain   = "vpc"

  tags = {
    Name = "EIP"
  }
}

resource "aws_nat_gateway" "nat" {
       allocation_id = aws_eip.eip.id
       subnet_id = aws_subnet.public_primary_subnet.id

tags = {
    Name = "nat_gateway"
}

}

resource "aws_route_table" "private_rt"{
    vpc_id = aws_vpc.main_vpc.id 

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat.id
    }
}

resource "aws_route_table_association" "private_rt_assoc1"{
        subnet_id = aws_subnet.private_primary_subnet.id
        route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc2"{
        subnet_id = aws_subnet.private_secondary_subnet.id
        route_table_id = aws_route_table.private_rt.id
}
