module "aws_vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "example_app" {
  source        = "./modules/ec2"
  name          = "web1"
  vpc_id        = module.aws_vpc.id
  cidr_block    = cidrsubnet(module.aws_vpc.cidr_block, 4, 1)
  ami           = "ami-0669b163befffbdfc"
  instance_type = "t2.micro"
}

