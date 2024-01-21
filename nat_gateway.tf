
# #####
#4. Elastic IP for NAT Gateway
resource "aws_eip" "yuran-nat-eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.yuran-nat-eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  tags = {
      Name = format("%s-EIP", var.name)
      }
    }
