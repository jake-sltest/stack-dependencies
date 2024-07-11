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

resource "aws_subnet" "deminar_subnet_1" {
    vpc_id = aws_vpc.sd_vpc.id
    cidr_block = "10.0.0.0/16"
    map_public_ip_on_launch = "true"

    tags = {
        deminar = "true"
    }
}

resource "aws_subnet" "deminar_subnet_2" {
    vpc_id = aws_vpc.sd_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"

    tags = {
        deminar = "true"
    }
}

output "subnetId" {
  description = "ID of the Subnet"
  value       = aws_subnet.deminar_subnet_1.id
}
