output "vpc_id" {
    value = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
    value = [aws_subnet.public_primary_subnet.id,
             aws_subnet.public_secondary_subnet.id
             ]
}

output "private_subnet_ids" {
    value = [aws_subnet.private_primary_subnet.id,
             aws_subnet.private_secondary_subnet.id
            ]
}