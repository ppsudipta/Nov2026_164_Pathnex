provider "aws" {
  region = "us-east-1"
}

# 1. VPC
resource "aws_vpc" "PathnexVPC" {
  cidr_block           = "10.14.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Pathnex-MiniProject-VPC"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "PathnexIGW" {
  vpc_id = aws_vpc.PathnexVPC.id

  tags = {
    Name = "Pathnex-MiniProject-IGW"
  }
}

# 3. Subnet
resource "aws_subnet" "PathnexSubnet" {
  vpc_id                  = aws_vpc.PathnexVPC.id
  cidr_block              = "10.14.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Pathnex-MiniProject-Subnet"
  }
}

# 4. Route Table
resource "aws_route_table" "PathnexRT" {
  vpc_id = aws_vpc.PathnexVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PathnexIGW.id
  }

  tags = {
    Name = "Pathnex-MiniProject-RouteTable"
  }
}

# 5. Route Table Association
resource "aws_route_table_association" "PathnexRTA" {
  subnet_id      = aws_subnet.PathnexSubnet.id
  route_table_id = aws_route_table.PathnexRT.id
}

# 6. Security Group
resource "aws_security_group" "PathnexSG" {
  name        = "pathnex-miniproject-sg"
  description = "Allow inbound HTTP and SSH traffic"
  vpc_id      = aws_vpc.PathnexVPC.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Pathnex-MiniProject-SG"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 7. EC2 Instance
resource "aws_instance" "PathnexEC2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "c5.xlarge"
  subnet_id              = aws_subnet.PathnexSubnet.id
  vpc_security_group_ids = [aws_security_group.PathnexSG.id]

  tags = {
    Name        = "Pathnex-MiniProject-EC2"
    Environment = "Production"
    Owner       = "Pathnex"
  }
}

output "instance_public_ip" {
  description = "Public IP of the provisioned EC2 instance"
  value       = aws_instance.PathnexEC2.public_ip
}

