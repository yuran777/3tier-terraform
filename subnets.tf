

#3. subnets

resource "aws_subnet" "public" {
  count                   = var.Desired_public_subnets
  vpc_id                  = aws_vpc.yuran-test-vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.aws_az_des, count.index)
  tags = {
    Name = format("%s-PublicSubnet-%s", var.name, element(var.aws_az_des, count.index))
  }
}
resource "aws_subnet" "private" {
  count                   = var.Desired_private_subnets
  vpc_id                  = aws_vpc.yuran-test-vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  # map_public_ip_on_launch = true
  availability_zone       = element(var.aws_az_des, count.index)
  tags = {
    Name = format("%s-PrivateSubnet-%s-%s", var.name, count.index, element(var.aws_az_des, count.index))
  }
}

resource "aws_subnet" "DB" {
  count                   = var.Desired_DB_subnets
  vpc_id                  = aws_vpc.yuran-test-vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 6)
  # map_public_ip_on_launch = true
  availability_zone       = element(var.aws_az_des, count.index)
  tags = {
    Name = format("%s-DBSubnet-%s", var.name, element(var.aws_az_des, count.index))
  }
}
