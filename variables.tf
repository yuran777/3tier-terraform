variable "region" {
  type    = string
  description = "The region to deploy resources"
  default = "ap-northeast-2"
}

variable "aws_az_des" {
  type    = list(string)
  description = "The region used in this project"
  default = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2a", "ap-northeast-2c"]
}

variable "aws_az" {
  type = list(string)
  description = "The az for nameming"
  default = [ "a","c" ]
  
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC cidr block"
  default = "10.10.0.0/16"
}

variable "name" {
  type = string
  description = "nanme for project"
  default = "yuran-test"
}

variable "Desired_public_subnets" {
  type        = number
  description = "Number of public subnets"
  default = 2
}

variable "Desired_private_subnets" {
  type        = number
  description = "Number of private subnets"
  default = 4
}

variable "Desired_DB_subnets" {
  type        = number
  description = "Number of DB subnets"
  default = 2
}

variable "keypair" {
  type        = string
  default = "yuran"
  description = "keypair for the ec2 instances"
}

variable "master-username" {
  type        = string
  description = "RDS Username for the Database"
  default = "yuran"
}

variable "master-password" {
  type        = string
  description = "RDS Password for the Database"
  default = "yuranyuran"
}