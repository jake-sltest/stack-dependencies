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

resource "aws_default_vpc" "sd_vpc" {

  tags = {
    Name = "Stack Dependency VPC"
  }
}

resource "aws_subnet" "sd_subnet" {
    vpc_id = aws_default_vpc.sd_vpc.id
    cidr_block = "10.0.0.0/16"
    map_public_ip_on_launch = "true"

    tags = {
        demo = "stack-dependencies"
    }
}

output "subnetId" {
  description = "ID of the Subnet"
  value       = aws_subnet.sd_subnet.id
}
