terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

variable "public_key" {
  description = "Public key for SSH access to Pathnex EC2 instance"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8N5dH3vS7m2oRFn04DkdyPuGWezk6p8OozdpHCrU+QCDM3KVDGXjd3M/rL2srhSXfGxuUXB3bRoyI4GGagHQZZfNabBBY+uThtsnhzySRmHuaZod+I5CFs38htEHrZHlJ3H7dbcw4qDcRtUKyZVyZCqNiQj808FDW4JSsIerZ86V8V6Y2oLPoe+MNxNduD4d/pTtGWPKNOdLV4egTWepbgCF4g2MKyThIniQ+XpeYxhdu6Fi2zI67FwlXxMqtZ16L1Pm5kagHiOw3MaXZE1CSr4mPfVQP+6Ppfu9rr7b91ywloOEONqMzcRGpW4DEutjXM4sdADPURANScVd0QtW1 ppsud@sudipta"
}

resource "aws_key_pair" "PathnexKey" {
  key_name   = "PathnexKey"
  public_key = var.public_key
}

resource "aws_instance" "PathnexEC2" {
  # Dynamically fetches the latest Amazon Linux 2023 AMI
  # (Course prompt uses static placeholder: "ami-0abcd1234abcd1234")
  ami           = data.aws_ami.amazon_linux.id
  # WARNING: c6i.8xlarge has 32 vCPUs / 64 GiB RAM (~$1.36/hr) and requires high AWS quota.
  # For local learning/free tier testing, you can change this to "t3.micro".
  instance_type = "c6i.8xlarge"
  key_name      = aws_key_pair.PathnexKey.key_name

  tags = {
    Name = "Pathnex-EC2"
  }
}

