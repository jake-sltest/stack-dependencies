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

resource "aws_instance" "sd_instace" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "Stack Dependency EC2"
  }
}

output "ec2Id" {
  description = "ID of the ec2 instance"
  value       = aws_instance.sd_instace.id
}