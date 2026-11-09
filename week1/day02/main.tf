provider "aws" {
  # Updated to your region: Asia Pacific (Sydney)
  region = "ap-southeast-2"
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
    Name        = "Pathnex-Server"
    Environment = "Training"
    Owner       = "PathnexStudent"
  }
}
