provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "PathnexVPC" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "Pathnex-VPC"
  }
}

resource "aws_subnet" "PathnexSubnet" {
  vpc_id                  = aws_vpc.PathnexVPC.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Pathnex-Subnet"
  }
}

resource "aws_lb" "PathnexALB" {
  name               = "pathnex-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.PathnexSubnet.id]

  tags = {
    Name = "Pathnex-ALB"
  }
}

resource "aws_lb_listener" "PathnexListener" {
  load_balancer_arn = aws_lb.PathnexALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Pathnex ALB Running"
      status_code  = "200"
    }
  }
}
