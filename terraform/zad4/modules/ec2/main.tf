terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }
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

  user_data = <<-EOL
    #!/bin/bash -xe
    sudo amazon-linux-extras enable nginx1.12
    sudo yum -y install nginx
    sudo systemctl start nginx
  EOL

  tags = {
    Name = var.name
  }
}


# user_data = <<-EOL
#   #!/bin/bash -xe

#   apt update
#   apt install openjdk-8-jdk --yes
#   wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
#   echo "deb https://pkg.jenkins.io/debian binary/" >> /etc/apt/sources.list
#   apt update
#   apt install -y jenkins
#   systemctl status jenkins
#   find /usr/lib/jvm/java-1.8* | head -n 3  
#   EOL

#   tags = {
#     Name = "HelloWorld"
#   }
# }