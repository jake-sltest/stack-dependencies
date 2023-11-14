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

data "spacelift_current_stack" "this" {}


resource "aws_instance" "sd_instance" {
  ami           = "ami-00aec864ef2480e7c"
  instance_type = "t2.micro"
  subnet_id = data.spacelift_current_stack.this.output.subnetId

  tags = {
    Name = "Stack Dependency EC2"
  }
}

output "ec2Id" {
  description = "ID of the ec2 instance"
  value       = aws_instance.sd_instance.id
}