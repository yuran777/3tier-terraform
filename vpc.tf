provider "aws" {
  region  = var.region
}

#1. vpc 
resource "aws_vpc" "yuran-test-vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = format("%s-VPC", var.name)
  }
}
