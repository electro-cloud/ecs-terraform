#create ALB and listening listeners

resource "aws_lb" "ecs_lb" {
  name               = "ecs-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [for subnet in aws_subnet.public_ecs_subnet : subnet.id]

  tags = {
    Name = "ecs-load-balancer"
  }
}

resource "aws_lb_target_group" "ecs_tg" {
  name     = "ecs-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecs_vpc.id
  target_type = "ip"

  health_check {
    path     = "/"
    protocol = "HTTP"
  }

  tags = {
    Name = "ecs-target-group"
  }
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }

  tags = {
    Name = "ecs-listener"
  }
}