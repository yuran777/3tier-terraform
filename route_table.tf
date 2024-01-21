
###route table


##2.1 route table for public subnets (igw)

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.yuran-test-vpc.id

  tags = {
      Name = format("%s-public-Route-Table", var.name)
    }
}

# create route for the private route table and attatch a nat gateway to it
resource "aws_route" "public-rtb-route" {
  route_table_id         = aws_route_table.public-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.yuran-test-igw.id
}


# associate all private subnets to the private route table
resource "aws_route_table_association" "public-subnets-assoc" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public-rtb.id
}



##4.1 route table for private subnets (natgw)

resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.yuran-test-vpc.id

  tags = {
      Name = format("%s-Private-Route-Table", var.name)
    }
}

# create route for the private route table and attatch a nat gateway to it
resource "aws_route" "private-rtb-route" {
  route_table_id         = aws_route_table.private-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.natgw.id
}


# associate all private subnets to the private route table
resource "aws_route_table_association" "private-subnets-assoc" {
  count          = length(aws_subnet.private[*].id) + length(aws_subnet.DB[*].id)
  subnet_id      = element(concat(aws_subnet.private[*].id, aws_subnet.DB[*].id), count.index)
  route_table_id = aws_route_table.private-rtb.id
}
