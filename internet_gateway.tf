
#2. igw
resource "aws_internet_gateway" "yuran-test-igw" {
  vpc_id = aws_vpc.yuran-test-vpc.id

  tags = {
    Name = format("%s-igw", var.name)
  }
}