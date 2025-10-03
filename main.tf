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


resource "aws_vpc" "worker_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "worker VPC"
  }
}


resource "aws_subnet" "worker_subnet" {
  vpc_id                  = aws_vpc.worker_vpc.id
  map_public_ip_on_launch = "true"
  cidr_block              = "10.0.1.0/24"



  tags = {
    demo = "worker Subnet"
  }
}

resource "aws_security_group" "worker_sg" {
  name        = "stack-dependency-demo"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.worker_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
