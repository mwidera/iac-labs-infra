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

resource "aws_instance" "web" {
	// AMI ID moze byc rozne w roznych regionach
    ami           = "ami-0a261c0e5f51090b1"
    instance_type = "t2.micro"
}
