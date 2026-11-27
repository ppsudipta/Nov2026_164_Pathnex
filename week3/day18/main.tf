provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "PathnexServer" {
  ami           = "ami-0abcd1234abcd1234"
  instance_type = var.instance_type
}

output "pathnex_ip" {
  value = aws_instance.PathnexServer.public_ip
}
