terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }
}

output "instance" {
  value = aws_instance.webserver
}

resource "aws_subnet" "webserver" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_block
}

resource "aws_instance" "webserver" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.webserver.id
  associate_public_ip_address = true
  tags = {
    Name = var.name
  }
}
