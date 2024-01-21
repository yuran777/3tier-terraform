####
## 6.1 ex-lb
resource "aws_lb" "external-lb"{
  name = "external-lb"
  internal = false	 # true = 내부(internal) / false = 외부(Internet-facing)
  load_balancer_type = "application" 
  security_groups = [aws_security_group.External-alb-sg.id]
  subnets = [aws_subnet.public[0].id, aws_subnet.public[1].id]
  # depends_on = [aws_ami_from_instance.app-layer-AS-template-ami] # AppEC2 완전 생성 후 ALB 생성 시작
  tags = {
      Name = format("%s-exelb", var.name)
  }
}

# ALB Target Groups
resource "aws_lb_target_group" "external-lb-tg"{
  name    = "external-lb-tg"
  port    = "80"
  protocol   = "HTTP"
  vpc_id  = aws_vpc.yuran-test-vpc.id
  target_type = "instance"
  
  health_check {
    path = "/index.html" 
    protocol = "HTTP"
    healthy_threshold  = 2 # 헬스 체크 문제 시, 정상 요청 반환이 될때까지의 최대 재요청 수(정상 간주)
    unhealthy_threshold = 2 # 헬스 체크 문제 시, 최대 실패 횟수 Limit
      # 결론은 헬스 체크 제대로 안될 때 최대 2번까지는 시도한다
    interval = 30 # 헬스 체크 인터벌(초)
    timeout = 5 # 해당 시간(초)내 응답이 없으면 실패 간주
  }

  tags = {
      Name = format("%s-exelb-tg", var.name)
  }
}

# ALB listener
resource "aws_lb_listener" "ex-lb-listner"{
  load_balancer_arn = aws_lb.external-lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.external-lb-tg.arn
  }
}

# 구성한 ALB에 attach할 대상 지정 (원본 인스턴스 Attach)
  # aws_lb_target_group_attachment의 경우 기존 원본 EC2 또는, 컨테이너, 람다 대상으로만 지정 가능
    # ASG에서 생성 된 인스턴스의 경우 aws_autoscaling_group에서 매개변수를 사용하여 타겟 그룹에 등록해야함
resource "aws_lb_target_group_attachment" "external-lb-attach-resource"{
  count = length(aws_instance.apache_web_server)
  target_group_arn = aws_lb_target_group.external-lb-tg.arn
  target_id = aws_instance.apache_web_server[count.index].id
  port = 80
  depends_on = [aws_lb_listener.ex-lb-listner]
}
# 만약 위 방식으로 ASG에서 생성된 인스턴스들의 Target_id를 별도로 지정 시, 에러 발생


####
## 6.2 in-lb

resource "aws_lb" "internal-lb"{
  name = "yuran-internal-lb"
  internal = true	 # true = 내부(internal) / false = 외부(Internet-facing)
  load_balancer_type = "network" 
  security_groups = [aws_security_group.internal-alb-sg.id]
  subnets = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  # depends_on = [aws_ami_from_instance.app-layer-AS-template-ami] # AppEC2 완전 생성 후 ALB 생성 시작
  tags = {
      Name = format("%s-inelb", var.name)
  }
}

# ALB Target Groups
resource "aws_lb_target_group" "internal-lb-tg"{
  name    = "internal-lb-tg"
  port    = "8080"
  protocol   = "TCP"
  vpc_id  = aws_vpc.yuran-test-vpc.id
  target_type = "instance"
  
  health_check {
    path = "/root/index.jsp" # 앞서 AppInstance 사전 구축 시, curl로 헬스 체크 테스트했던 경로
    protocol = "HTTP"
    healthy_threshold  = 2 # 헬스 체크 문제 시, 정상 요청 반환이 될때까지의 최대 재요청 수(정상 간주)
    unhealthy_threshold = 2 # 헬스 체크 문제 시, 최대 실패 횟수 Limit
      # 결론은 헬스 체크 제대로 안될 때 최대 2번까지는 시도한다
    interval = 30 # 헬스 체크 인터벌(초)
    timeout = 5 # 해당 시간(초)내 응답이 없으면 실패 간주
  }

  tags = {
      Name = format("%s-inelb-tg", var.name)
  }
}

# ALB listener
resource "aws_lb_listener" "app-alb-listner"{
  load_balancer_arn = aws_lb.internal-lb.arn
  port = "8080"
  protocol = "TCP"
  default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.internal-lb-tg.arn
  }
}

# 구성한 ALB에 attach할 대상 지정 (원본 인스턴스 Attach)
  # aws_lb_target_group_attachment의 경우 기존 원본 EC2 또는, 컨테이너, 람다 대상으로만 지정 가능
    # ASG에서 생성 된 인스턴스의 경우 aws_autoscaling_group에서 매개변수를 사용하여 타겟 그룹에 등록해야함
resource "aws_lb_target_group_attachment" "internal-alb-attach-resource"{
  count = length(aws_instance.tomcat_server)
  target_group_arn = aws_lb_target_group.internal-lb-tg.arn
  target_id = aws_instance.tomcat_server[count.index].id
  port = 8080
  depends_on = [aws_lb_listener.app-alb-listner]
}
# 만약 위 방식으로 ASG에서 생성된 인스턴스들의 Target_id를 별도로 지정 시, 에러 발생