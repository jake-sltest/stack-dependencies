resource "spacelift_stack" "vpc-stack" {
  administrative               = false
  space_id                     = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  branch                       = "main"
  description                  = "This stack creates a VPC"
  labels                       = ["sd-demo"]
  name                         = "vpc-stack"
  project_root                 = "/infrastructure/terraform/vpc"
  repository                   = "stack-dependencies"
  terraform_smart_sanitization = false
  autodeploy        = true
}

resource "spacelift_stack" "ec2-stack" {
  administrative               = false
  space_id                     = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  branch                       = "main"
  description                  = "This stack creates an ec2 instanc"
  labels                       = ["sd-demo"]
  name                         = "ec2-stack"
  project_root                 = "/infrastructure/terraform/instances"
  repository                   = "stack-dependencies"
  terraform_smart_sanitization = true
  autodeploy        = true
}

resource "spacelift_stack" "ansible-stack" {
  administrative               = false
  space_id                     = "stack-dependencies-demo-01HES50MW0R4XW1AME0BPP8YVY"
  branch                       = "main"
  description                  = "This stack configures the deployed ec2 using ansible"
  labels                       = ["sd-demo"]
  name                         = "ansible-stack"
  project_root                 = "/ansible"
  repository                   = "stack-dependencies"
  terraform_smart_sanitization = true
  autodeploy        = true
}

resource "spacelift_stack_dependency" "ec2-depends-on-vpc" {
  stack_id            = spacelift_stack.ec2-stack.id
  depends_on_stack_id = spacelift_stack.vpc-stack.id
}

resource "spacelift_stack_dependency" "ansible-depends-on-ec2" {
  stack_id            = spacelift_stack.ansible-stack.id
  depends_on_stack_id = spacelift_stack.ec2-stack.id
}