
# security group for bastion, to allow access into the bastion host from you IP
resource "aws_security_group" "bastion_sg" {
  name        = "vpc_bastion_sg"
  vpc_id      = aws_vpc.yuran-test-vpc.id
  description = "Allow remote SSH connections."

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags ={
      Name = format("%s-Bastion-SG", var.name)
}
}

# security group for External ALB
resource "aws_security_group" "External-alb-sg" {
  name   = "External-alb-sg"
  description = "Internet facing alb sg"
  vpc_id = aws_vpc.yuran-test-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      Name = format("%s-exelb-sg", var.name)
    }
}


# security group for webservers, to have access only from the internal load balancer and bastion instance
resource "aws_security_group" "webserver-sg" {
  name   = "my-web-sg"
  description = "web server sg"
  vpc_id = aws_vpc.yuran-test-vpc.id
 
  ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_groups = [aws_security_group.External-alb-sg.id]
  # 처음에 생성한 External ALB SG를 Inbound로 허용하도록 구성
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["10.10.5.0/24"]
    }

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["10.10.5.0/24"]
    }

  tags = {
      Name = format("%s-web-sg", var.name)
    }

}
# Internal ALB SG
resource "aws_security_group" "internal-alb-sg" {
  name = "internal-alb-sg"
  description = "Internal ALB Between Web-App"
  vpc_id = aws_vpc.yuran-test-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.webserver-sg.id]
    # webserver-sg에서 인바운드 되는 트래픽 허용
  }

    ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.webserver-sg.id]
    # webserver-sg에서 인바운드 되는 트래픽 허용
  }

  egress { 
    from_port = 0
    to_port = 0
    protocol = "-1" # Protocol -1은 전체 프로토콜을 의미
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      Name = format("%s-inelb-sg", var.name)
  }
}

# was 보안 그룹 생성
resource "aws_security_group" "was-sg" {
  name = "was-sg"
  description = "was sg"
  vpc_id = aws_vpc.yuran-test-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.internal-alb-sg.id]
    # 내부 ALB SG와 전체 주소 허용이 된, 4000TCP 포트로 트래픽 수신 설정
    # 해당 4000번 포트는 ALB LB Target Group Register Port로 설정 사항에 따라 변동 가능
  }

    ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["10.10.4.0/24"]
    }

    ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["10.10.5.0/24"]
    # 내부 ALB SG와 전체 주소 허용이 된, 4000TCP 포트로 트래픽 수신 설정
    # 해당 4000번 포트는 ALB LB Target Group Register Port로 설정 사항에 따라 변동 가능
  }

  egress { 
    from_port = 0
    to_port = 0
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      Name = format("%s-was-sg", var.name)
  }  
}

# DB 보안 그룹 생성
resource "aws_security_group" "db-sg" {
  name = "db-sg"
  description = "database security group"
  vpc_id = aws_vpc.yuran-test-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.External-alb-sg.id]
    # 처음에 생성한 External ALB SG를 Inbound로 허용하도록 구성
  }

    ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.was-sg.id]
    # 처음에 생성한 External ALB SG를 Inbound로 허용하도록 구성
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # Protocol -1은 전체 프로토콜을 의미
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "db-sg"
  }
}