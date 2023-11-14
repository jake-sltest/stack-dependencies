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

resource "aws_instance" "sd_instance" {
  ami           = "ami-00aec864ef2480e7c"
  instance_type = "t2.micro"
  subnet_id = var.subnetId

  tags = {
    Name = "Stack Dependency EC2"
  }
}

resource "spacelift_environment_variable" "ansible_confg_var" {
  context_id = spacelift_context.ansible-context.id
  name       = "ANSIBLE_INVENTORY"
  value      = "/mnt/workspace/aws_ec2.yml"
  write_only = false
}

data "template_file" "aws_dynamic_inventory" {
  template = "${file("${path.module}/templates/aws_ec2.tpl")}"
  vars = {
    aws_region = "us-east-1"
    spacelift_stack_id = spacelift_stack.ec2-stack.id
  }
}

resource "spacelift_mounted_file" "aws_inventory" {
  context_id    = spacelift_context.ansible-context.id
  relative_path = "aws_ec2.yml"
  content       = base64encode(data.template_file.aws_dynamic_inventory.rendered)
  write_only    = false
}

resource "spacelift_context_attachment" "attachment" {
  context_id = spacelift_context.ansible-context.id
  stack_id   = spacelift_stack.ansible-stack.id
  priority   = 0
}

output "ec2Id" {
  description = "ID of the ec2 instance"
  value       = aws_instance.sd_instance.id
}