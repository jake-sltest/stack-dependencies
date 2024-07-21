terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}


provider "spacelift" {
}

variable "subnetId" {
  type = string
  default = ""
}

variable "public_key" {
  
}

resource "aws_instance" "sd_instance" {
  ami           = "ami-00aec864ef2480e7c"
  instance_type = "t2.micro"
  subnet_id = var.subnetId
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  
  tags = {
    Name = "Stack Dependency EC2 change"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ec2"
  public_key = file(var.public_key)
}

output "aws_instance_ip" {
  description = "IP of the ec2 instance"
  value       = aws_instance.sd_instance.public_ip
}