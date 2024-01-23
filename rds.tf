# RDS Subnet Group 생성
resource "aws_db_subnet_group" "db-subnet-group" {
  name = format("%s-db-subnet-group", var.name)
  subnet_ids = aws_subnet.DB[*].id
}

resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = "db.t3.micro"
  db_name                = "yurandb"
  username               = var.master-username
  password               = var.master-password
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db-sg.id]


  tags = {"name" = format("%s-RDS", var.name)
}
}

