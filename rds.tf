# # RDS Subnet Group 생성
# resource "aws_db_subnet_group" "db-subnet-group" {
#   name = "three-tier-db-subnet-group"
#   subnet_ids = aws_subnet.DB[*].id
# }

# resource "aws_db_instance" "rds" {
#   allocated_storage      = 8
#   engine                 = "mysql"
#   engine_version         = "8.0"
#   instance_class         = local.database_instance_class
#   db_name                = "terraform_3_tier_architecture"
#   username               = var.master-username
#   password               = var.master-password
#   db_subnet_group_name   = aws_db_subnet_group.private_db_subnet_group.name
#   skip_final_snapshot    = true
#   vpc_security_group_ids = var.security_group_ids


#   tags = {"name" = format("%s-RDS", var.name)
# }

