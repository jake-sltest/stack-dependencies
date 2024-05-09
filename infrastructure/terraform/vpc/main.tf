terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "sd_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Stack Dependency VPC"
  }
}

resource "aws_subnet" "sd_subnet_new" {
    vpc_id = aws_vpc.sd_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"

    tags = {
        Name = "Stack Dependency Public Subnet"
    }
}

resource "aws_instance" "second_instance" {
  ami           = "ami-00aec864ef2480e7c"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.sd_subnet.id

  tags = {
    Name = "tag test two"
  }
}

