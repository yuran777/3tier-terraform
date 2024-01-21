resource "aws_instance" "bastion" {
  ami                    = "ami-0c8f3f68c379ed6c1"  

  #aws ec2 describe-images \
  # --owners amazon \
  # --filters "Name=name,Values=amzn2-ami-hvm-2.0.*-x86_64-gp2" \
  # --query "Images | [0].ImageId" \
  # --output text

  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, This is bastion" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  key_name = "yuran"  

  tags = {
    Name = "bastion"
  }
}



# Web Server (Apache)
resource "aws_instance" "apache_web_server" {
  count                  = 2
  ami                    = "ami-04ab8d3a67dfe6398"
  instance_type          = "t3.small"
  subnet_id = element([aws_subnet.private[0].id, aws_subnet.private[1].id], count.index)
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  # associate_public_ip_address = true

  key_name = "yuran"

  tags = {
    Name = format("apache-web-server-%s", element(var.aws_az, count.index))
}
}

# Was Server
resource "aws_instance" "tomcat_server" {
  count                  = 2
  ami                    = "ami-04ab8d3a67dfe6398"  
  instance_type          = "t3.small"
  subnet_id = element([aws_subnet.private[2].id, aws_subnet.private[3].id], count.index)
  vpc_security_group_ids = [aws_security_group.was-sg.id]
  # associate_public_ip_address = true

  key_name = "yuran"


  tags = {
    Name = format("tomcat-was-server-%s", element(var.aws_az, count.index))
  }
}
