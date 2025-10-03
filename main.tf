terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}


resource "aws_vpc" "sd_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Stack Dependency VPC"
  }
}


resource "aws_subnet" "sd_subnet" {
  vpc_id                  = aws_vpc.sd_vpc.id
  map_public_ip_on_launch = "true"
  cidr_block              = "10.0.1.0/24"



  tags = {
    demo = "Stack Dependency Subnet"
  }
}

resource "aws_security_group" "allow_access" {
  name        = "stack-dependency-demo"
  description = "Allow SSH, HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.sd_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8000
    to_port     = 8000
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
    Name = "Stack Dependency EC2"
  }
}
