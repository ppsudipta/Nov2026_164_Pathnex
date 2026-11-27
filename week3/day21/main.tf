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
  instance_type = "c5.xlarge"

  tags = {
    Name  = "Pathnex-EC2"
    Owner = "PathnexStudent"
  }
}
