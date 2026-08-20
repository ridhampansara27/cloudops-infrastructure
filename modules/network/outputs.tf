# Return VPC ID.
output "vpc_id" {

  value = aws_vpc.this.id
}


# Return public subnet IDs.
output "public_subnet_ids" {

  value = aws_subnet.public[*].id
}


# Return Internet Gateway ID.
output "internet_gateway_id" {

  value = aws_internet_gateway.this.id
}