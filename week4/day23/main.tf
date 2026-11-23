provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "PathnexEC2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  tags = {
    Name = "Pathnex-EC2"
  }
}

resource "aws_eip" "PathnexEIP" {
  instance = aws_instance.PathnexEC2.id

  tags = {
    Name = "Pathnex-EIP"
  }
}
