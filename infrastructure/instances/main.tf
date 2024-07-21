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

resource "aws_key_pair" "ssh_key" {
  key_name   = "ec2-key-pair"
  public_key = file(var.public_key)
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