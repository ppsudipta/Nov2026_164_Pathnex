provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "Bad" {
  ami           = "ami-123"
  instance_type = "c6i.8xlarge"
}
