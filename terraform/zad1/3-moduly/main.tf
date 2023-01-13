terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

module "aws_vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "aws_vpc_east" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"

  providers = {
    aws = aws.east
  }

}
module "webserver" {
  source        = "./modules/ec2"
  name          = "web1"
  vpc_id        = module.aws_vpc.id
  cidr_block    = cidrsubnet(module.aws_vpc.cidr_block, 4, 1)
  ami           = "ami-0a261c0e5f51090b1"
  instance_type = "t2.micro"
}

module "webserver2" {
  source        = "./modules/ec2"
  name          = "web2"
  vpc_id        = module.aws_vpc_east.id
  cidr_block    = cidrsubnet(module.aws_vpc_east.cidr_block, 4, 2)
  ami           = "ami-0a261c0e5f51090b1" # Zmodyfikuj mnie do wlasciwej wartosci
  instance_type = "t2.micro"

  providers = {
    aws = aws.east
  }
}

output "webserver" {
  value = module.webserver.instance.public_ip
}

