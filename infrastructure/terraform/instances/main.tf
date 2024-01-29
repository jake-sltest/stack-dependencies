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
  default = "subnet-06222b16d1f7d8a9e"
}

resource "aws_instance" "sd_instance" {
  ami           = "ami-00aec864ef2480e7c"
  instance_type = "t2.micro"
  subnet_id = var.subnetId

  tags = {
    Name = "Stack Dependency EC2 change"
  }
}

resource "aws_instance" "second_instance" {
  ami           = "ami-00aec864ef2480e7c"
  instance_type = "t2.micro"
  subnet_id = var.subnetId

  tags = {
    Name = "tag test"
  }
}

output "ec2Id" {
  description = "ID of the ec2 instance"
  value       = "SPACELIFT: The ec2 instance id output is: ${aws_instance.sd_instance.id}"
}