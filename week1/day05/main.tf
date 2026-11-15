terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
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
  # Dynamically fetches the latest Amazon Linux 2023 AMI; fallback placeholder: "ami-0abcd1234abcd1234"
  ami           = data.aws_ami.amazon_linux.id
  # WARNING: c6a.12xlarge has 48 vCPUs / 96 GiB RAM (~$1.82/hr) and requires high AWS quota.
  # For local learning/free tier testing, you can change this to "t3.micro".
  instance_type = "c6a.12xlarge"

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "Pathnex-EC2"
  }
}

