provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "PathnexVPC" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "Pathnex-VPC"
  }
}

resource "aws_security_group" "PathnexSG" {
  name   = "pathnex-sg"
  vpc_id = aws_vpc.PathnexVPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Pathnex-SG"
  }
}
